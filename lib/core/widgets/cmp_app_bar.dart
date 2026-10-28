import 'package:flutter/material.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_colors.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';
import 'package:vehicle_speed_estimator/core/widgets/cmp_brand_stripe.dart';

/// Standard CMP Command Console App Bar.
/// Reference: AGENT.md Section 11.
class CmpAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CmpAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBrandStripe = false,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBrandStripe;
  final Widget? leading;

  @override
  Size get preferredSize => Size.fromHeight(showBrandStripe ? 67.0 : 64.0);

  @override
  Widget build(BuildContext context) {
    final colors = context.cmp;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          backgroundColor: colors.surface,
          foregroundColor: colors.textPrimary,
          elevation: 0,
          leading: leading,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: CmpTypography.headline.copyWith(
                  color: colors.textPrimary,
                  fontSize: subtitle != null ? 18.0 : 22.0,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: CmpTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
            ],
          ),
          actions: actions,
        ),
        if (showBrandStripe) const CmpBrandStripe(),
      ],
    );
  }
}
