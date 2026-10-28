import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_colors.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';
import 'package:vehicle_speed_estimator/core/widgets/cmp_app_bar.dart';
import 'package:vehicle_speed_estimator/core/widgets/cmp_button.dart';
import 'package:vehicle_speed_estimator/core/widgets/step_indicator.dart';
import 'package:vehicle_speed_estimator/features/calibration/domain/calibration_notifier.dart';

class SessionSetupScreen extends ConsumerStatefulWidget {
  const SessionSetupScreen({super.key});

  @override
  ConsumerState<SessionSetupScreen> createState() => _SessionSetupScreenState();
}

class _SessionSetupScreenState extends ConsumerState<SessionSetupScreen> {
  final _siteController = TextEditingController();
  final _limitController = TextEditingController();
  bool _isTwoWay = false;

  @override
  void dispose() {
    _siteController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _onContinue() {
    final site = _siteController.text.trim();
    if (site.isEmpty) return;

    final limit = double.tryParse(_limitController.text.trim());
    ref
        .read(calibrationNotifierProvider.notifier)
        .updateSessionParams(
          siteName: site,
          speedLimitKmh: limit,
          isTwoWay: _isTwoWay,
        );

    context.push('/calibration/map');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.cmp;
    final isSiteValid = _siteController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: CmpAppBar(
        title: 'সেশন সেটআপ / Setup',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: CmpSpacing.space16),
              child: StepIndicator(currentStep: 1),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(CmpSpacing.space16),
                children: [
                  Text(
                    'সাইটের নাম / Site Name *',
                    style: CmpTypography.label.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: CmpSpacing.space8),
                  TextField(
                    controller: _siteController,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: colors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'যেমন: জিইসি মোড় / e.g. GEC Circle',
                      hintStyle: TextStyle(color: colors.textSecondary),
                      filled: true,
                      fillColor: colors.surfaceHigh,
                      border: OutlineInputBorder(
                        borderRadius: CmpSpacing.borderCard,
                        borderSide: BorderSide(color: colors.outline),
                      ),
                    ),
                  ),
                  const SizedBox(height: CmpSpacing.space24),
                  Text(
                    'গতির সীমা / Speed Limit (km/h)',
                    style: CmpTypography.label.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: CmpSpacing.space8),
                  TextField(
                    controller: _limitController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: colors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'যেমন: ৬০ / e.g. 60',
                      hintStyle: TextStyle(color: colors.textSecondary),
                      filled: true,
                      fillColor: colors.surfaceHigh,
                      border: OutlineInputBorder(
                        borderRadius: CmpSpacing.borderCard,
                        borderSide: BorderSide(color: colors.outline),
                      ),
                    ),
                  ),
                  const SizedBox(height: CmpSpacing.space24),
                  Text(
                    'রাস্তার ধরন / Road Type',
                    style: CmpTypography.label.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: CmpSpacing.space8),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: false,
                        label: Text('একমুখী / One-Way'),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text('দ্বিমুখী / Two-Way'),
                      ),
                    ],
                    selected: {_isTwoWay},
                    onSelectionChanged: (set) =>
                        setState(() => _isTwoWay = set.first),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(CmpSpacing.space16),
              child: CmpButton(
                label: 'পরবর্তী / Continue',
                onPressed: isSiteValid ? _onContinue : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
