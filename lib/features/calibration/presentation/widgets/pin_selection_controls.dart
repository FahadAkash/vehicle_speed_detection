import 'package:flutter/material.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_colors.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';
import 'package:vehicle_speed_estimator/core/widgets/cmp_button.dart';

class PinSelectionControls extends StatelessWidget {
  const PinSelectionControls({
    required this.selectingPinA,
    required this.canContinue,
    required this.onSelectPinAChanged,
    required this.onUndo,
    required this.onDropPin,
    required this.onContinue,
    required this.onSelectFallback,
    super.key,
  });

  final bool selectingPinA;
  final bool canContinue;
  final ValueChanged<bool> onSelectPinAChanged;
  final VoidCallback onUndo;
  final VoidCallback onDropPin;
  final VoidCallback? onContinue;
  final VoidCallback onSelectFallback;

  @override
  Widget build(BuildContext context) {
    final colors = context.cmp;

    return Container(
      padding: const EdgeInsets.all(CmpSpacing.space16),
      color: colors.surface.withValues(alpha: 0.95),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      label: Text('পিন এ / Pin A'),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text('পিন বি / Pin B'),
                    ),
                  ],
                  selected: {selectingPinA},
                  onSelectionChanged: (set) => onSelectPinAChanged(set.first),
                ),
              ),
              const SizedBox(width: CmpSpacing.space8),
              IconButton.outlined(
                icon: const Icon(Icons.undo),
                onPressed: onUndo,
              ),
            ],
          ),
          const SizedBox(height: CmpSpacing.space12),
          Row(
            children: [
              Expanded(
                child: CmpButton(
                  label: 'পিন বসান / Drop Pin',
                  icon: Icons.pin_drop,
                  variant: CmpButtonVariant.secondary,
                  onPressed: onDropPin,
                ),
              ),
              const SizedBox(width: CmpSpacing.space12),
              Expanded(
                child: CmpButton(
                  label: 'পরবর্তী / Continue',
                  onPressed: canContinue ? onContinue : null,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: onSelectFallback,
            child: Text(
              'চিহ্ন দেখতে পাচ্ছেন না? ডিফল্ট ৩০মি নির্বাচন করুন',
              style: CmpTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

