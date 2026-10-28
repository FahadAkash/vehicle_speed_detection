import 'package:flutter/material.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_colors.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';
import 'package:vehicle_speed_estimator/core/utils/number_formatter.dart';

/// Sync status card with retry tap action.
/// Reference: AGENT.md Section 9.1 & Section 11.
class SyncStatusCard extends StatelessWidget {
  const SyncStatusCard({
    super.key,
    required this.pendingCount,
    required this.onRetrySync,
    this.useBanglaDigits = false,
  });

  final int pendingCount;
  final VoidCallback onRetrySync;
  final bool useBanglaDigits;

  @override
  Widget build(BuildContext context) {
    final colors = context.cmp;
    final formattedPending = NumberFormatter.formatInt(
      pendingCount,
      useBanglaDigits: useBanglaDigits,
    );

    final isAllSynced = pendingCount == 0;
    final statusColor = isAllSynced ? colors.verified : colors.warningText;
    final message = isAllSynced
        ? 'সব রেকর্ড সিঙ্ক হয়েছে / All records synced'
        : '$formattedPending টি রেকর্ড সিঙ্ক বাকি / records pending sync';

    return Material(
      color: colors.surfaceHigh,
      shape: RoundedRectangleBorder(
        borderRadius: CmpSpacing.borderCard,
        side: BorderSide(color: colors.outline),
      ),
      child: InkWell(
        onTap: onRetrySync,
        borderRadius: CmpSpacing.borderCard,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CmpSpacing.space16,
            vertical: CmpSpacing.space12,
          ),
          child: Row(
            children: [
              Icon(
                isAllSynced ? Icons.cloud_done : Icons.sync,
                color: statusColor,
                size: 20.0,
              ),
              const SizedBox(width: CmpSpacing.space12),
              Expanded(
                child: Text(
                  message,
                  style: CmpTypography.label.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colors.textSecondary,
                size: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
