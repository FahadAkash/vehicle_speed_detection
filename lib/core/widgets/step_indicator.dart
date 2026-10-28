import 'package:flutter/material.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_colors.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';

/// 4-step progress indicator for calibration workflow.
/// Reference: AGENT.md Section 11.
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  final int currentStep; // 1-based index (1 to 4)
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final colors = context.cmp;

    return Semantics(
      label:
          'ধাপ $currentStep এর $totalSteps / Step $currentStep of $totalSteps',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(totalSteps, (index) {
          final stepNum = index + 1;
          final color = stepNum < currentStep
              ? colors.verified
              : (stepNum == currentStep ? colors.primary : colors.outline);

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: CmpSpacing.space4),
            width: stepNum == currentStep ? 24.0 : 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: color,
              borderRadius: CmpSpacing.borderPill,
            ),
          );
        }),
      ),
    );
  }
}
