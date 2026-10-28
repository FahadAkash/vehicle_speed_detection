import 'package:flutter/material.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';
import 'package:vehicle_speed_estimator/core/theme/overlay_colors.dart';
import 'package:vehicle_speed_estimator/core/widgets/stability_pill.dart';
import 'package:vehicle_speed_estimator/core/widgets/status_pill.dart';

/// Top HUD bar for live monitor per AGENT.md Section 9.5 wireframe.
class MonitorTopBar extends StatelessWidget {
  const MonitorTopBar({
    required this.onStop,
    required this.isPaused,
    required this.inferenceMs,
    required this.isSteady,
    required this.distanceM,
    this.fps = 30,
    super.key,
  });

  final VoidCallback onStop;
  final bool isPaused;
  final int inferenceMs;
  final bool isSteady;
  final double distanceM;
  final int fps;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            onPressed: onStop,
          ),
          const SizedBox(width: CmpSpacing.space12),
          StatusPill(
            status: isPaused ? MonitoringStatus.paused : MonitoringStatus.armed,
          ),
          const SizedBox(width: CmpSpacing.space12),
          Text(
            '$fps FPS',
            style: CmpTypography.caption.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: CmpSpacing.space12),
          Text(
            '$inferenceMs ms',
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
    );
  }
}

