import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vehicle_speed_estimator/core/services/background_isolate_worker.dart';
import 'package:vehicle_speed_estimator/core/services/camera_service.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';
import 'package:vehicle_speed_estimator/core/theme/overlay_colors.dart';
import 'package:vehicle_speed_estimator/core/widgets/cmp_banner.dart';
import 'package:vehicle_speed_estimator/core/widgets/live_camera_preview.dart';
import 'package:vehicle_speed_estimator/core/widgets/stability_pill.dart';
import 'package:vehicle_speed_estimator/core/widgets/status_pill.dart';
import 'package:vehicle_speed_estimator/core/widgets/verified_feed_tile.dart';
import 'package:vehicle_speed_estimator/features/calibration/domain/calibration_notifier.dart';
import 'package:vehicle_speed_estimator/features/settings/domain/settings_notifier.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/tracked_vehicle_state.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/verified_speed_record.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/presentation/widgets/monitor_overlay_painter.dart';
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
      timestampUs: _stopwatch.elapsedMicroseconds,
      currentGyro: cal.currentGyro,
      currentUtcMs: DateTime.now().millisecondsSinceEpoch,
      siteName: cal.config.siteName,
      speedLimitKmh: cal.config.speedLimitKmh,
    );
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
            child: Container(
              color: OverlayColors.overlayScrim,
              padding: const EdgeInsets.symmetric(
                horizontal: CmpSpacing.space16,
                vertical: 8,
              ),
              child: Row(
                children: [
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: Colors.red),
                    icon: const Icon(Icons.stop, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: CmpSpacing.space12),
                  StatusPill(
                    status: _isPaused
                        ? MonitoringStatus.paused
                        : MonitoringStatus.armed,
                  ),
                  const SizedBox(width: CmpSpacing.space12),
                  Text(
                    '$_inferenceMs ms',
                    style: CmpTypography.caption.copyWith(color: Colors.white),
                  ),
                  const Spacer(),
                  StabilityPill(isSteady: calState.isSteady),
                  const SizedBox(width: CmpSpacing.space12),
                  Text(
                    'D = ${calState.config.distanceM.toStringAsFixed(1)} m',
                    style: CmpTypography.label.copyWith(color: Colors.white),
                  ),
                ],
              ),
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
          Positioned(
            top: 48,
            right: 0,
            bottom: 64,
            width: 220,
            child: Container(
              color: OverlayColors.overlayScrim,
              padding: const EdgeInsets.all(CmpSpacing.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LATEST VERIFIED',
                    style: CmpTypography.caption.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: CmpSpacing.space8),
                  Expanded(
                    child: _verifiedFeed.isEmpty
                      ? Center(
                          child: Text(
                            'অপেক্ষমান...',
                            style: CmpTypography.caption.copyWith(
                              color: Colors.white54,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _verifiedFeed.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: VerifiedFeedTile(record: _verifiedFeed[i]),
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: OverlayColors.overlayScrim,
              height: 64,
              padding: const EdgeInsets.symmetric(
                horizontal: CmpSpacing.space16,
              ),
              child: Row(
                children: [
                  Text(
                    'Verified: ${_verifiedFeed.length}',
                    style: CmpTypography.title.copyWith(color: Colors.white),
                  ),
                  if (diagnosticsOn) ...[
                    const SizedBox(width: CmpSpacing.space16),
                    Text(
                      'Faults: 0 | Dropped: ${_worker.droppedFramesCount}',
                      style: CmpTypography.caption.copyWith(
                        color: Colors.yellow,
                      ),
                    ),
                  ],
                  const Spacer(),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: _isPaused ? Colors.green : Colors.orange,
                      minimumSize: const Size(56, 44),
                    ),
                    icon: Icon(
                      _isPaused ? Icons.play_arrow : Icons.pause,
                      color: Colors.white,
                    ),
                    onPressed: () => setState(() => _isPaused = !_isPaused),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
