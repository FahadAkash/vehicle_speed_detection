import 'package:flutter/material.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_colors.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';
import 'package:vehicle_speed_estimator/core/utils/number_formatter.dart';

/// On-video / detail speed badge.
/// Reference: AGENT.md Section 9.5 & Section 11.
class SpeedChip extends StatelessWidget {
  const SpeedChip({
    super.key,
    required this.speedKmh,
    this.speedLimitKmh,
    this.useBanglaDigits = false,
    this.isLarge = false,
  });

  final double speedKmh;
  final double? speedLimitKmh;
  final bool useBanglaDigits;
  final bool isLarge;

  bool get isOverLimit => speedLimitKmh != null && speedKmh > speedLimitKmh!;

  @override
  Widget build(BuildContext context) {
    final colors = context.cmp;
    final bgColor = isOverLimit ? colors.dangerFill : colors.verified;
    final textColor = colors.onPrimary;

    final formattedSpeed = NumberFormatter.formatSpeed(
      speedKmh,
      useBanglaDigits: useBanglaDigits,
      fractionDigits: isLarge ? 1 : 0,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? CmpSpacing.space16 : CmpSpacing.space12,
        vertical: isLarge ? CmpSpacing.space8 : CmpSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: CmpSpacing.borderPill,
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOverLimit) ...[
            Icon(
              Icons.warning_rounded,
              color: textColor,
              size: isLarge ? 20.0 : 16.0,
            ),
            const SizedBox(width: CmpSpacing.space4),
          ],
          Text(
            '$formattedSpeed km/h',
            style: (isLarge ? CmpTypography.title : CmpTypography.label)
                .copyWith(color: textColor, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
