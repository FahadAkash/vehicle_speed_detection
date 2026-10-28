import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';
import 'package:vehicle_speed_estimator/core/theme/overlay_colors.dart';
import 'package:vehicle_speed_estimator/core/widgets/cmp_banner.dart';
import 'package:vehicle_speed_estimator/core/widgets/stability_pill.dart';
import 'package:vehicle_speed_estimator/core/widgets/status_pill.dart';
import 'package:vehicle_speed_estimator/core/widgets/verified_feed_tile.dart';
import 'package:vehicle_speed_estimator/features/calibration/domain/calibration_notifier.dart';
import 'package:vehicle_speed_estimator/features/settings/domain/settings_notifier.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/tracked_vehicle_state.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/verified_speed_record.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class LiveMonitorScreen extends ConsumerStatefulWidget {
  const LiveMonitorScreen({super.key});

  @override
  ConsumerState<LiveMonitorScreen> createState() => _LiveMonitorScreenState();
}

class _LiveMonitorScreenState extends ConsumerState<LiveMonitorScreen> {
  bool _isPaused = false;
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
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _tracksNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calState = ref.watch(calibrationNotifierProvider);
    final diagnosticsOn = ref.watch(
      settingsNotifierProvider.select((s) => s.diagnosticsMode),
    );
    final distanceM = calState.config.distanceM;
    final isSteady = calState.isSteady;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview layer
          const RepaintBoundary(
            child: SizedBox.expand(child: ColoredBox(color: Color(0xFF0F172A))),
          ),
          // Bounding box & gates layer
          RepaintBoundary(
            child: CustomPaint(
              size: Size.infinite,
              painter: _BoundingBoxPainter(_tracksNotifier),
            ),
          ),
          // Top HUD Bar
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
                    '30 FPS · 18 ms',
                    style: CmpTypography.caption.copyWith(color: Colors.white),
                  ),
                  const Spacer(),
                  StabilityPill(isSteady: isSteady),
                  const SizedBox(width: CmpSpacing.space12),
                  Text(
                    'D = ${distanceM.toStringAsFixed(1)} m',
                    style: CmpTypography.label.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          // Tripod shake warning banner
          if (!isSteady)
            const Positioned(
              top: 56,
              left: 100,
              right: 100,
              child: CmpBanner(
                message: 'ক্যামেরা নড়ে গেছে — ফোনটি স্থির রাখুন / Hold steady',
                variant: CmpBannerVariant.warning,
              ),
            ),
          // Right Feed Panel
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
          // Bottom Bar
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
                      'Faults: 0 | Dropped: 0',
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

class _BoundingBoxPainter extends CustomPainter {
  _BoundingBoxPainter(this.tracksNotifier) : super(repaint: tracksNotifier);
  final ValueNotifier<List<TrackedVehicleState>> tracksNotifier;

  @override
  void paint(Canvas canvas, Size size) {
    final paintBox = Paint()
      ..color = OverlayColors.trackedBox
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final track in tracksNotifier.value) {
      final rect = Rect.fromLTRB(
        track.left * size.width,
        track.top * size.height,
        track.right * size.width,
        track.bottom * size.height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        paintBox,
      );
    }
  }

  @override
  bool shouldRepaint(_BoundingBoxPainter oldDelegate) => false;
}
