import 'package:flutter/material.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';
import 'package:vehicle_speed_estimator/core/theme/overlay_colors.dart';

/// Bottom HUD bar for live monitor per AGENT.md Section 9.5 wireframe.
class MonitorBottomBar extends StatelessWidget {
  const MonitorBottomBar({
    required this.verifiedCount,
    required this.diagnosticsOn,
    required this.droppedFramesCount,
    required this.isPaused,
    required this.onTogglePause,
    required this.onTestCar,
    super.key,
  });

  final int verifiedCount;
  final bool diagnosticsOn;
  final int droppedFramesCount;
  final bool isPaused;
  final VoidCallback onTogglePause;
  final VoidCallback onTestCar;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: OverlayColors.overlayScrim,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: CmpSpacing.space16),
      child: Row(
        children: [
          Text(
            'Verified $verifiedCount',
            style: CmpTypography.title.copyWith(color: Colors.white),
          ),
          if (diagnosticsOn) ...[
            const SizedBox(width: CmpSpacing.space16),
            Text(
              'Faults: 0 | Dropped: $droppedFramesCount',
              style: CmpTypography.caption.copyWith(color: Colors.yellow),
            ),
          ],
          const Spacer(),
          IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: isPaused ? Colors.green : Colors.orange,
              minimumSize: const Size(64, 48),
            ),
            icon: Icon(
              isPaused ? Icons.play_arrow : Icons.pause,
              color: Colors.white,
              size: 28,
            ),
            onPressed: onTogglePause,
          ),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            icon: const Icon(Icons.directions_car, size: 18),
            label: const Text('টেস্ট গাড়ি / Test Car'),
            onPressed: onTestCar,
          ),
        ],
      ),
    );
  }
}

