import 'package:flutter/material.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';
import 'package:vehicle_speed_estimator/core/theme/overlay_colors.dart';
import 'package:vehicle_speed_estimator/core/widgets/cmp_button.dart';
import 'package:vehicle_speed_estimator/core/widgets/stability_pill.dart';

/// Top bar for Gate Alignment per AGENT.md Section 9.4 wireframe.
class GateAlignmentTopBar extends StatelessWidget {
  const GateAlignmentTopBar({
    required this.onBack,
    required this.isSteady,
    required this.distanceM,
    super.key,
  });

  final VoidCallback onBack;
  final bool isSteady;
  final double distanceM;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: OverlayColors.overlayScrim,
      padding: const EdgeInsets.symmetric(
        horizontal: CmpSpacing.space16,
        vertical: 8,
      ),
      child: Row(
        children: [
          IconButton.filled(
            style: IconButton.styleFrom(backgroundColor: Colors.white24),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onBack,
          ),
          const SizedBox(width: CmpSpacing.space12),
          Text(
            'গেট সারিবদ্ধকরণ / Align Gates',
            style: CmpTypography.title.copyWith(color: Colors.white),
          ),
          const Spacer(),
          StabilityPill(isSteady: isSteady),
          const SizedBox(width: CmpSpacing.space12),
          Text(
            'D = ${distanceM.toStringAsFixed(1)} m',
            style: CmpTypography.label.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Bottom controls for Gate Alignment per AGENT.md Section 9.4 wireframe.
class GateAlignmentBottomBar extends StatelessWidget {
  const GateAlignmentBottomBar({
    required this.onReset,
    required this.onConfirm,
    required this.isConfirmEnabled,
    super.key,
  });

  final VoidCallback onReset;
  final VoidCallback? onConfirm;
  final bool isConfirmEnabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CmpSpacing.space16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CmpButton(
            label: 'রিসেট / Reset',
            variant: CmpButtonVariant.secondary,
            isFullWidth: false,
            onPressed: onReset,
          ),
          CmpButton(
            label: 'গেট নিশ্চিত করুন / Confirm Gates',
            isFullWidth: false,
            onPressed: isConfirmEnabled ? onConfirm : null,
          ),
        ],
      ),
    );
  }
}

