import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_colors.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';
import 'package:vehicle_speed_estimator/core/utils/number_formatter.dart';
import 'package:vehicle_speed_estimator/core/widgets/vehicle_class_icon.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/verified_speed_record.dart';

/// Single verified vehicle record tile.
/// Reference: AGENT.md Section 11.
class VerifiedFeedTile extends StatelessWidget {
  const VerifiedFeedTile({
    super.key,
    required this.record,
    this.onTap,
    this.useBanglaDigits = false,
  });

  final VerifiedSpeedRecord record;
  final VoidCallback? onTap;
  final bool useBanglaDigits;

  @override
  Widget build(BuildContext context) {
    final colors = context.cmp;
    final date = DateTime.fromMillisecondsSinceEpoch(record.timestampUtcMs)
        .toLocal();
    final timeStr = DateFormat('HH:mm:ss').format(date);
    final formattedTime = NumberFormatter.formatDigits(
      timeStr,
      useBanglaDigits: useBanglaDigits,
    );
    final formattedSpeed = NumberFormatter.formatSpeed(
      record.speedKmh,
      useBanglaDigits: useBanglaDigits,
    );

    final speedColor = record.isOverLimit ? colors.dangerText : colors.verified;
    final directionArrow = record.direction == 'A_TO_B' ? '→' : '←';

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: CmpSpacing.borderCard,
        side: BorderSide(color: colors.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: CmpSpacing.borderCard,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CmpSpacing.space16,
            vertical: CmpSpacing.space12,
          ),
          child: Row(
            children: [
              VehicleClassIcon(
                vehicleClass: record.vehicleClass,
                color: colors.textPrimary,
                size: 28.0,
              ),
              const SizedBox(width: CmpSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      record.vehicleClass.banglaLabel,
                      style: CmpTypography.label.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      '$directionArrow  $formattedTime',
                      style: CmpTypography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$formattedSpeed km/h',
                    style: CmpTypography.tabular(
                      CmpTypography.title,
                    ).copyWith(color: speedColor, fontWeight: FontWeight.w700),
                  ),
                  Icon(
                    record.isSynced ? Icons.cloud_done : Icons.cloud_off,
                    size: 14.0,
                    color: record.isSynced
                        ? colors.verified
                        : colors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
