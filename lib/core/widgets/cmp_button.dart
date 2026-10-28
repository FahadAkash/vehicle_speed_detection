import 'package:flutter/material.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_colors.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';

enum CmpButtonVariant { primary, secondary, destructive, ghost }

/// Accessible outdoor action button.
/// Reference: AGENT.md Section 11.
class CmpButton extends StatelessWidget {
  const CmpButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CmpButtonVariant.primary,
    this.icon,
    this.height = CmpSpacing.primaryButtonHeight,
    this.isFullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final CmpButtonVariant variant;
  final IconData? icon;
  final double height;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.cmp;
    final isEnabled = onPressed != null;

    final (bgColor, fgColor, borderColor) = switch (variant) {
      CmpButtonVariant.primary => (
        colors.primary,
        colors.onPrimary,
        Colors.transparent,
      ),
      CmpButtonVariant.secondary => (
        colors.surfaceHigh,
        colors.textPrimary,
        colors.outline,
      ),
      CmpButtonVariant.destructive => (
        colors.dangerFill,
        colors.onPrimary,
        Colors.transparent,
      ),
      CmpButtonVariant.ghost => (
        Colors.transparent,
        colors.textPrimary,
        Colors.transparent,
      ),
    };

    final content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20.0, color: fgColor),
          const SizedBox(width: CmpSpacing.space8),
        ],
        Text(label, style: CmpTypography.label.copyWith(color: fgColor)),
      ],
    );

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.40,
      child: SizedBox(
        height: height,
        width: isFullWidth ? double.infinity : null,
        child: Material(
          color: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: CmpSpacing.borderCard,
            side: BorderSide(color: borderColor),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: CmpSpacing.borderCard,
            splashFactory: isEnabled
                ? InkRipple.splashFactory
                : NoSplash.splashFactory,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CmpSpacing.space16,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
