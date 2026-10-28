import 'package:flutter/material.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_colors.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';

/// Gyro steadiness pill for tripod stability.
/// Reference: AGENT.md Section 11.
class StabilityPill extends StatelessWidget {
  const StabilityPill({super.key, required this.isSteady});

  final bool isSteady;

  @override
  Widget build(BuildContext context) {
    final colors = context.cmp;
    final color = isSteady ? colors.verified : colors.warningText;
    final icon = isSteady ? Icons.screen_lock_landscape : Icons.vibration;
    final label = isSteady ? 'স্থির / Steady' : 'নড়ছে / Moving';

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
          Icon(icon, size: 14.0, color: color),
          const SizedBox(width: CmpSpacing.space8),
          Text(
            label,
            style: CmpTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
