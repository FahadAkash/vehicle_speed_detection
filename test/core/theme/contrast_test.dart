import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_colors.dart';

double _luminance(Color color) {
  double channel(double v) {
    return v <= 0.04045
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

double _contrastRatio(Color a, Color b) {
  final l1 = _luminance(a);
  final l2 = _luminance(b);
  final brighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (brighter + 0.05) / (darker + 0.05);
}

void main() {
  group('WCAG Contrast Contract', () {
    test('Dark theme text contrast ratios >= 4.5:1', () {
      const c = CmpColors.dark;

      expect(
        _contrastRatio(c.textPrimary, c.background),
        greaterThanOrEqualTo(4.5),
        reason: 'textPrimary on background',
      );
      expect(
        _contrastRatio(c.textPrimary, c.surface),
        greaterThanOrEqualTo(4.5),
        reason: 'textPrimary on surface',
      );
      expect(
        _contrastRatio(c.textSecondary, c.background),
        greaterThanOrEqualTo(4.5),
        reason: 'textSecondary on background',
      );
      expect(
        _contrastRatio(c.onPrimary, c.primary),
        greaterThanOrEqualTo(4.5),
        reason: 'onPrimary on primary',
      );
    });

    test('Light theme text contrast ratios >= 4.5:1', () {
      const c = CmpColors.light;

      expect(
        _contrastRatio(c.textPrimary, c.background),
        greaterThanOrEqualTo(4.5),
        reason: 'textPrimary on background',
      );
      expect(
        _contrastRatio(c.textPrimary, c.surface),
        greaterThanOrEqualTo(4.5),
        reason: 'textPrimary on surface',
      );
      expect(
        _contrastRatio(c.textSecondary, c.background),
        greaterThanOrEqualTo(4.5),
        reason: 'textSecondary on background',
      );
      expect(
        _contrastRatio(c.onPrimary, c.primary),
        greaterThanOrEqualTo(4.5),
        reason: 'onPrimary on primary',
      );
    });
  });
}
