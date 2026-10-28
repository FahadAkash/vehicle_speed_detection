import 'package:flutter/material.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_colors.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';

/// Large numeric card for dashboard and session statistics.
/// Reference: AGENT.md Section 11.
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
  });

  final String label;
  final String value;
  final String? unit;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.cmp;

    return Container(
      padding: const EdgeInsets.all(CmpSpacing.space16),
      decoration: BoxDecoration(
        color: colors.surfaceHigh,
        borderRadius: CmpSpacing.borderCard,
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16.0, color: colors.textSecondary),
                const SizedBox(width: CmpSpacing.space8),
              ],
              Expanded(
                child: Text(
                  label,
                  style: CmpTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: CmpSpacing.space8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: CmpTypography.speedDisplay.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: CmpSpacing.space4),
                Text(
                  unit!,
                  style: CmpTypography.label.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
