import 'package:flutter/material.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_colors.dart';

/// 3 dp three-segment decorative crest accent stripe.
/// Ratio: brandGreen 60% / brandRed 25% / brandYellow 15%.
/// Reference: AGENT.md Section 7.6.
class CmpBrandStripe extends StatelessWidget {
  const CmpBrandStripe({super.key, this.height = 3.0});

  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.cmp;
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(flex: 60, child: Container(color: colors.brandGreen)),
          Expanded(flex: 25, child: Container(color: colors.brandRed)),
          Expanded(flex: 15, child: Container(color: colors.brandYellow)),
        ],
      ),
    );
  }
}
