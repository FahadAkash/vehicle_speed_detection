import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vehicle_speed_estimator/core/constants/vehicle_classes.dart';
import 'package:vehicle_speed_estimator/core/services/background_isolate_worker.dart';
import 'package:vehicle_speed_estimator/core/services/camera_service.dart';
import 'package:vehicle_speed_estimator/core/widgets/cmp_banner.dart';
import 'package:vehicle_speed_estimator/core/widgets/live_camera_preview.dart';
import 'package:vehicle_speed_estimator/features/calibration/domain/calibration_notifier.dart';
import 'package:vehicle_speed_estimator/features/settings/domain/settings_notifier.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/tracked_vehicle_state.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/verified_speed_record.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/presentation/widgets/monitor_bottom_bar.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/presentation/widgets/monitor_feed_panel.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/presentation/widgets/monitor_overlay_painter.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/presentation/widgets/monitor_top_bar.dart';
import 'package:vehicle_speed_estimator/features/telemetry_sync/domain/telemetry_providers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class LiveMonitorScreen extends ConsumerStatefulWidget {
  const LiveMonitorScreen({super.key});

  @override
  ConsumerState<LiveMonitorScreen> createState() => _LiveMonitorScreenState();
}

class _LiveMonitorScreenState extends ConsumerState<LiveMonitorScreen> {
  CameraController? _cameraController;
  final BackgroundIsolateWorker _worker = BackgroundIsolateWorker();
  StreamSubscription<TrackingFrameResult>? _workerSub;
  final Stopwatch _stopwatch = Stopwatch()..start();
  bool _isPaused = false;
  int _inferenceMs = 0;
  final ValueNotifier<List<TrackedVehicleState>> _tracksNotifier =
      ValueNotifier([]);
  final List<VerifiedSpeedRecord> _verifiedFeed = [];

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startSystem();
  }

  Future<void> _startSystem() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return;

    final calState = ref.read(calibrationNotifierProvider);
    await _worker.start(
      gates: calState.gates,
      distanceM: calState.config.distanceM,
    );

    _workerSub = _worker.resultsStream.listen((res) {
      if (!mounted) return;
      _tracksNotifier.value = res.activeTracks;
      _inferenceMs = res.inferenceMs;
      if (res.verifiedRecords.isNotEmpty) {
        setState(() {
          for (final r in res.verifiedRecords) {
            _verifiedFeed.insert(0, r);
            ref.read(databaseProvider).insertRecord(r);
          }
        });
      }
    });

    final cam = await ref.read(cameraServiceProvider).initialize();
    if (mounted) {
      setState(() => _cameraController = cam);
      await ref.read(cameraServiceProvider).startStream(_onFrame);
    }
  }

  void _onFrame(CameraImage image) {
    if (_isPaused || !mounted) return;
    final cal = ref.read(calibrationNotifierProvider);
    _worker.dispatchFrame(
      frameBytes: image.planes[0].bytes,
      width: image.width,
      height: image.height,
      bytesPerRow: image.planes[0].bytesPerRow,
      timestampUs: _stopwatch.elapsedMicroseconds,
      currentGyro: cal.currentGyro,
      currentUtcMs: DateTime.now().millisecondsSinceEpoch,
      siteName: cal.config.siteName,
      speedLimitKmh: cal.config.speedLimitKmh,
    );
  }

  void _runTestCarSimulation() {
    final cal = ref.read(calibrationNotifierProvider);
    final distanceM = cal.config.distanceM > 0 ? cal.config.distanceM : 30.0;
    const speedMs = 54.0 / 3.6;
    final gA = cal.gateA?.p1.x ?? 0.25;
    final gB = cal.gateB?.p1.x ?? 0.75;
    final span = (gB - gA).abs();
    final normPerSec = speedMs * (span / distanceM);

    double currX = 0.05;
    final startUs = _stopwatch.elapsedMicroseconds;
    int step = 0;

    Timer.periodic(const Duration(milliseconds: 33), (timer) {
      if (!mounted || currX > 0.95) {
        timer.cancel();
        return;
      }
      step++;
      final frameTimeUs = startUs + (step * 33333);
      final track = TrackedVehicleState(
        trackId: 101 + _verifiedFeed.length,
        vehicleClass: VehicleClass.car,
        left: currX,
        top: 0.40,
        right: currX + 0.12,
        bottom: 0.65,
        vx: normPerSec,
        vy: 0.0,
        colorHistogram: const [],
        lastSeenTimeUs: frameTimeUs,
      );
      _tracksNotifier.value = [track];
      currX += normPerSec * 0.033333;

      if (currX >= gB && !_verifiedFeed.any((r) => r.trackId == track.trackId)) {
        final rec = VerifiedSpeedRecord(
          trackId: track.trackId,
          vehicleClass: VehicleClass.car,
          speedKmh: 53.8,
          speedHalf1Kmh: 54.0,
          speedHalf2Kmh: 53.6,
          direction: 'A_TO_B',
          distanceM: distanceM,
          timestampUtcMs: DateTime.now().millisecondsSinceEpoch,
          siteName: cal.config.siteName.isEmpty ? 'Test Road' : cal.config.siteName,
          speedLimitKmh: cal.config.speedLimitKmh,
        );
        setState(() => _verifiedFeed.insert(0, rec));
        ref.read(databaseProvider).insertRecord(rec);
      }
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _workerSub?.cancel();
    _worker.stop();
    ref.read(cameraServiceProvider).stopStream();
    _tracksNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calState = ref.watch(calibrationNotifierProvider);
    final diagnosticsOn = ref.watch(
      settingsNotifierProvider.select((s) => s.diagnosticsMode),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          LiveCameraPreview(controller: _cameraController),
          RepaintBoundary(
            child: CustomPaint(
              size: Size.infinite,
              painter: MonitorOverlayPainter(
                tracksNotifier: _tracksNotifier,
                gateA: calState.gateA,
                gateB: calState.gateB,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: MonitorTopBar(
              onStop: () => context.pop(),
              isPaused: _isPaused,
              inferenceMs: _inferenceMs,
              isSteady: calState.isSteady,
              distanceM: calState.config.distanceM,
            ),
          ),
          if (!calState.isSteady)
            const Positioned(
              top: 56,
              left: 100,
              right: 100,
              child: CmpBanner(
                message: 'ক্যামেরা নড়ে গেছে — ফোনটি স্থির রাখুন / Hold steady',
                variant: CmpBannerVariant.warning,
              ),
            ),
          MonitorFeedPanel(verifiedFeed: _verifiedFeed),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MonitorBottomBar(
              verifiedCount: _verifiedFeed.length,
              diagnosticsOn: diagnosticsOn,
              droppedFramesCount: _worker.droppedFramesCount,
              isPaused: _isPaused,
              onTogglePause: () => setState(() => _isPaused = !_isPaused),
              onTestCar: _runTestCarSimulation,
            ),
          ),
        ],
      ),
    );
  }
}

