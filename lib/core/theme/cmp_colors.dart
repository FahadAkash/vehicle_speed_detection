import 'package:flutter/material.dart';

/// CMP Design System semantic color tokens.
/// Reference: AGENT.md Section 7.3.
class CmpColors extends ThemeExtension<CmpColors> {
  const CmpColors({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.outline,
    required this.textPrimary,
    required this.textSecondary,
    required this.primary,
    required this.onPrimary,
    required this.verified,
    required this.warningFill,
    required this.warningText,
    required this.dangerFill,
    required this.dangerText,
    required this.brandGreen,
    required this.brandRed,
    required this.brandYellow,
  });

  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color outline;
  final Color textPrimary;
  final Color textSecondary;
  final Color primary;
  final Color onPrimary;
  final Color verified;
  final Color warningFill;
  final Color warningText;
  final Color dangerFill;
  final Color dangerText;
  final Color brandGreen;
  final Color brandRed;
  final Color brandYellow;

  static const CmpColors dark = CmpColors(
    background: Color(0xFF0A1020),
    surface: Color(0xFF111A2E),
    surfaceHigh: Color(0xFF18243D),
    outline: Color(0xFF2B3A5C),
    textPrimary: Color(0xFFF3F6FB),
    textSecondary: Color(0xFFA3B0C8),
    primary: Color(0xFF007A38),
    onPrimary: Color(0xFFFFFFFF),
    verified: Color(0xFF2FD27A),
    warningFill: Color(0xFFFFED00),
    warningText: Color(0xFFFFED00),
    dangerFill: Color(0xFFE30613),
    dangerText: Color(0xFFFF5A63),
    brandGreen: Color(0xFF008D3F),
    brandRed: Color(0xFFE30613),
    brandYellow: Color(0xFFFFED00),
  );

  static const CmpColors light = CmpColors(
    background: Color(0xFFF3F6FA),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFE8EDF5),
    outline: Color(0xFFC5CEDD),
    textPrimary: Color(0xFF0A1020),
    textSecondary: Color(0xFF4A5873),
    primary: Color(0xFF007A38),
    onPrimary: Color(0xFFFFFFFF),
    verified: Color(0xFF007A38),
    warningFill: Color(0xFFFFED00),
    warningText: Color(0xFF8A6D00),
    dangerFill: Color(0xFFE30613),
    dangerText: Color(0xFFC4050F),
    brandGreen: Color(0xFF008D3F),
    brandRed: Color(0xFFE30613),
    brandYellow: Color(0xFFFFED00),
  );

  @override
  ThemeExtension<CmpColors> copyWith({
    Color? background,
    Color? surface,
    Color? surfaceHigh,
    Color? outline,
    Color? textPrimary,
    Color? textSecondary,
    Color? primary,
    Color? onPrimary,
    Color? verified,
    Color? warningFill,
    Color? warningText,
    Color? dangerFill,
    Color? dangerText,
    Color? brandGreen,
    Color? brandRed,
    Color? brandYellow,
  }) {
    return CmpColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      outline: outline ?? this.outline,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      verified: verified ?? this.verified,
      warningFill: warningFill ?? this.warningFill,
      warningText: warningText ?? this.warningText,
      dangerFill: dangerFill ?? this.dangerFill,
      dangerText: dangerText ?? this.dangerText,
      brandGreen: brandGreen ?? this.brandGreen,
      brandRed: brandRed ?? this.brandRed,
      brandYellow: brandYellow ?? this.brandYellow,
    );
  }

  @override
  ThemeExtension<CmpColors> lerp(ThemeExtension<CmpColors>? other, double t) {
    if (other is! CmpColors) return this;
    return CmpColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      verified: Color.lerp(verified, other.verified, t)!,
      warningFill: Color.lerp(warningFill, other.warningFill, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
      dangerFill: Color.lerp(dangerFill, other.dangerFill, t)!,
      dangerText: Color.lerp(dangerText, other.dangerText, t)!,
      brandGreen: Color.lerp(brandGreen, other.brandGreen, t)!,
      brandRed: Color.lerp(brandRed, other.brandRed, t)!,
      brandYellow: Color.lerp(brandYellow, other.brandYellow, t)!,
    );
  }
}

/// Convenience context extension to access CmpColors.
extension CmpColorsExtension on BuildContext {
  CmpColors get cmp => Theme.of(this).extension<CmpColors>() ?? CmpColors.dark;
}
