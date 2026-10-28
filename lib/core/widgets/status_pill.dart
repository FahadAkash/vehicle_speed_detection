import 'package:flutter/material.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_colors.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';

enum MonitoringStatus { armed, paused, syncing }

/// ARMED / PAUSED / SYNCING live status pill.
/// Reference: AGENT.md Section 11.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final MonitoringStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.cmp;

    final (label, icon, color) = switch (status) {
      MonitoringStatus.armed => (
        'সক্রিয় / ARMED',
        Icons.circle,
        colors.verified,
      ),
      MonitoringStatus.paused => (
        'স্থগিত / PAUSED',
        Icons.pause_circle_filled,
        colors.warningText,
      ),
      MonitoringStatus.syncing => (
        'সিঙ্ক হচ্ছে / SYNCING',
        Icons.sync,
        colors.primary,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CmpSpacing.space12,
        vertical: CmpSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: CmpSpacing.borderPill,
        border: Border.all(color: color, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.0, color: color),
          const SizedBox(width: CmpSpacing.space8),
          Text(
            label,
            style: CmpTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
