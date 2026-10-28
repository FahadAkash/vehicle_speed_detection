import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:vehicle_speed_estimator/core/constants/vehicle_classes.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/logic/robust_vehicle_tracker.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/logic/speed_math_engine.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/tracked_vehicle_state.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/verified_speed_record.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/virtual_gate.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/yolo_detection.dart';

class TrackingFrameResult {
  const TrackingFrameResult({
    required this.activeTracks,
    required this.verifiedRecords,
    required this.inferenceMs,
    required this.droppedFramesCount,
  });

  final List<TrackedVehicleState> activeTracks;
  final List<VerifiedSpeedRecord> verifiedRecords;
  final int inferenceMs;
  final int droppedFramesCount;
}

class BackgroundIsolateWorker {
  Isolate? _isolate;
  ReceivePort? _receivePort;
  SendPort? _workerSendPort;
  bool _isProcessingFrame = false;
  int _droppedFramesCount = 0;

  final _resultController = StreamController<TrackingFrameResult>.broadcast();
  Stream<TrackingFrameResult> get resultsStream => _resultController.stream;

  bool get isProcessingFrame => _isProcessingFrame;
  int get droppedFramesCount => _droppedFramesCount;

  Future<void> start({
    required List<VirtualGate> gates,
    required double distanceM,
  }) async {
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_workerEntryPoint, _receivePort!.sendPort);

    final completer = Completer<void>();
    _receivePort!.listen((message) {
      if (message is SendPort) {
        _workerSendPort = message;
        _workerSendPort!.send({
          'type': 'INIT',
          'gates': gates,
          'distanceM': distanceM,
        });
        completer.complete();
      } else if (message is Map<String, dynamic>) {
        _isProcessingFrame = false;
        final tracks = message['tracks'] as List<TrackedVehicleState>;
        final verified = message['verified'] as List<VerifiedSpeedRecord>;
        final inferenceMs = message['inferenceMs'] as int;

        _resultController.add(
          TrackingFrameResult(
            activeTracks: tracks,
            verifiedRecords: verified,
            inferenceMs: inferenceMs,
            droppedFramesCount: _droppedFramesCount,
          ),
        );
      }
    });

    await completer.future;
  }

  bool dispatchFrame({
    required Uint8List frameBytes,
    required int width,
    required int height,
    required int timestampUs,
    required double currentGyro,
    required int currentUtcMs,
    String siteName = '',
    double? speedLimitKmh,
  }) {
    if (_isProcessingFrame || _workerSendPort == null) {
      _droppedFramesCount++;
      return false;
    }

    _isProcessingFrame = true;
    final transferable = TransferableTypedData.fromList([frameBytes]);

    _workerSendPort!.send({
      'type': 'FRAME',
      'transferable': transferable,
      'width': width,
      'height': height,
      'timestampUs': timestampUs,
      'currentGyro': currentGyro,
      'currentUtcMs': currentUtcMs,
      'siteName': siteName,
      'speedLimitKmh': speedLimitKmh,
    });
    return true;
  }

  void stop() {
    _workerSendPort?.send({'type': 'STOP'});
    _receivePort?.close();
    _isolate?.kill(priority: Isolate.immediate);
    _resultController.close();
  }

  static void _workerEntryPoint(SendPort mainSendPort) {
    final port = ReceivePort();
    mainSendPort.send(port.sendPort);

    final tracker = RobustVehicleTracker();
    final mathEngine = SpeedMathEngine();
    List<VirtualGate> gates = [];
    double distanceM = 30.0;
    Uint8List? prevGrid;

    port.listen((msg) {
      if (msg is! Map<String, dynamic>) return;
      final type = msg['type'] as String;

      if (type == 'INIT') {
        gates = msg['gates'] as List<VirtualGate>;
        distanceM = msg['distanceM'] as double;
      } else if (type == 'FRAME') {
        final stopwatch = Stopwatch()..start();
        final transferable = msg['transferable'] as TransferableTypedData;
        final bytes = transferable.materialize().asUint8List();
        final width = msg['width'] as int;
        final height = msg['height'] as int;
        final timestampUs = msg['timestampUs'] as int;
        final currentGyro = msg['currentGyro'] as double;
        final currentUtcMs = msg['currentUtcMs'] as int;
        final siteName = msg['siteName'] as String;
        final speedLimitKmh = msg['speedLimitKmh'] as double?;

        final currGrid = Uint8List(32 * 24);
        final detections = _detectMotion(bytes, width, height, prevGrid, currGrid);
        prevGrid = currGrid;

        final verified = tracker.processFrame(
          detections: detections,
          frameTimeUs: timestampUs,
          gates: gates,
          mathEngine: mathEngine,
          distanceM: distanceM,
          currentGyro: currentGyro,
          currentUtcMs: currentUtcMs,
          siteName: siteName,
          speedLimitKmh: speedLimitKmh,
        );

        stopwatch.stop();

        mainSendPort.send({
          'tracks': tracker.activeTracks,
          'verified': verified,
          'inferenceMs': stopwatch.elapsedMilliseconds,
        });
      } else if (type == 'STOP') {
        port.close();
      }
    });
  }

  static List<YoloDetection> _detectMotion(
    Uint8List bytes,
    int width,
    int height,
    Uint8List? prevGrid,
    Uint8List currGrid,
  ) {
    const gw = 32, gh = 24;
    final stepX = width ~/ gw, stepY = height ~/ gh;
    if (stepX <= 0 || stepY <= 0) return const [];

    for (int gy = 0; gy < gh; gy++) {
      for (int gx = 0; gx < gw; gx++) {
        final px = (gx * stepX) + (stepX ~/ 2);
        final py = (gy * stepY) + (stepY ~/ 2);
        final idx = py * width + px;
        currGrid[gy * gw + gx] = idx < bytes.length ? bytes[idx] : 0;
      }
    }

    if (prevGrid == null) return const [];

    int minGx = gw, maxGx = -1, minGy = gh, maxGy = -1;
    int motionCount = 0;

    for (int i = 0; i < currGrid.length; i++) {
      final diff = (currGrid[i] - prevGrid[i]).abs();
      if (diff > 22) {
        final gx = i % gw;
        final gy = i ~/ gw;
        minGx = min(minGx, gx);
        maxGx = max(maxGx, gx);
        minGy = min(minGy, gy);
        maxGy = max(maxGy, gy);
        motionCount++;
      }
    }

    if (motionCount < 6 || maxGx < minGx || maxGy < minGy) return const [];

    final bW = (maxGx - minGx + 1);
    final bH = (maxGy - minGy + 1);
    if (bW < 2 || bH < 2 || bW > 28 || bH > 22) return const [];

    final left = (minGx / gw).clamp(0.05, 0.90);
    final top = (minGy / gh).clamp(0.05, 0.90);
    final right = ((maxGx + 1) / gw).clamp(0.10, 0.95);
    final bottom = ((maxGy + 1) / gh).clamp(0.10, 0.95);

    final ar = (right - left) / (bottom - top);
    VehicleClass vClass = VehicleClass.car;
    if (ar < 0.6) {
      vClass = VehicleClass.motorcycle;
    } else if (ar > 1.6) {
      vClass = VehicleClass.bus;
    } else if (ar < 1.0) {
      vClass = VehicleClass.cng;
    }

    return [
      YoloDetection(
        vehicleClass: vClass,
        confidence: 0.82,
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        histogram: List.filled(24, 1.0 / 24.0),
      ),
    ];
  }
}
