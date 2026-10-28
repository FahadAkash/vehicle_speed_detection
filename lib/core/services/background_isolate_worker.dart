import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

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

  /// Dispatches frame with Rule 1 Frame-Drop Gate.
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
      return false; // Dropped immediately
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

    port.listen((msg) {
      if (msg is! Map<String, dynamic>) return;
      final type = msg['type'] as String;

      if (type == 'INIT') {
        gates = msg['gates'] as List<VirtualGate>;
        distanceM = msg['distanceM'] as double;
      } else if (type == 'FRAME') {
        final stopwatch = Stopwatch()..start();
        final timestampUs = msg['timestampUs'] as int;
        final currentGyro = msg['currentGyro'] as double;
        final currentUtcMs = msg['currentUtcMs'] as int;
        final siteName = msg['siteName'] as String;
        final speedLimitKmh = msg['speedLimitKmh'] as double?;

        final detections = <YoloDetection>[];

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
}
