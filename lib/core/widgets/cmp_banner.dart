import 'package:flutter/material.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_colors.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';

enum CmpBannerVariant { info, warning, error }

/// Non-blocking alert banner for field use.
/// Reference: AGENT.md Section 11.
class CmpBanner extends StatelessWidget {
  const CmpBanner({
    super.key,
    required this.message,
    this.variant = CmpBannerVariant.info,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final CmpBannerVariant variant;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.cmp;

    final (bgColor, fgColor, icon) = switch (variant) {
      CmpBannerVariant.info => (
        colors.surfaceHigh,
        colors.textPrimary,
        Icons.info_outline,
      ),
      CmpBannerVariant.warning => (
        colors.warningFill,
        const Color(0xFF0A1020),
        Icons.warning_amber_rounded,
      ),
      CmpBannerVariant.error => (
        colors.dangerFill,
        Colors.white,
        Icons.error_outline,
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: CmpSpacing.space16,
        vertical: CmpSpacing.space12,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: CmpSpacing.borderCard,
      ),
      child: Row(
        children: [
          Icon(icon, color: fgColor, size: 20.0),
          const SizedBox(width: CmpSpacing.space12),
          Expanded(
            child: Text(
              message,
              style: CmpTypography.body.copyWith(
                color: fgColor,
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: CmpSpacing.space8),
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: CmpTypography.label.copyWith(color: fgColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
