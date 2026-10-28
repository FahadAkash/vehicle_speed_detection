import 'package:flutter/material.dart';
import 'package:vehicle_speed_estimator/core/constants/app_constants.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_colors.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';
import 'package:vehicle_speed_estimator/core/utils/number_formatter.dart';

/// Floating badge displaying calibration distance and status.
/// Reference: AGENT.md Section 9.3 & Section 11.
class DistanceBadge extends StatelessWidget {
  const DistanceBadge({
    super.key,
    required this.distanceM,
    this.useBanglaDigits = false,
  });

  final double distanceM;
  final bool useBanglaDigits;

  @override
  Widget build(BuildContext context) {
    final colors = context.cmp;

    final Color color;
    final IconData icon;
    final String statusText;
    if (distanceM < AppConstants.minGateDistanceM) {
      color = colors.warningText;
      icon = Icons.warning_amber_rounded;
      statusText = 'খুব কম / Too short';
    } else if (distanceM > AppConstants.recommendedGateDistanceMax) {
      color = colors.textSecondary;
      icon = Icons.info_outline;
      statusText = 'দীর্ঘ ব্যবধান / Long span';
    } else {
      color = colors.verified;
      icon = Icons.check_circle_outline;
      statusText = 'সঠিক / Good';
    }

    final distStr = NumberFormatter.formatDistance(
      distanceM,
      useBanglaDigits: useBanglaDigits,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CmpSpacing.space16,
        vertical: CmpSpacing.space8,
      ),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.95),
        borderRadius: CmpSpacing.borderPill,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.0, color: color),
          const SizedBox(width: CmpSpacing.space8),
          Text(
            'D = $distStr m',
            style: CmpTypography.title.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: CmpSpacing.space8),
          Text(
            '· $statusText',
            style: CmpTypography.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
