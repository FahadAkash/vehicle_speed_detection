import 'package:flutter/material.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_colors.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';

/// CMP Design System Theme builder.
/// Reference: AGENT.md Section 7.
abstract final class CmpTheme {
  static ThemeData build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colors = isDark ? CmpColors.dark : CmpColors.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      fontFamily: CmpTypography.fontPrimary,
      fontFamilyFallback: CmpTypography.fontFallbacks,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.brandGreen,
        onSecondary: colors.onPrimary,
        error: colors.dangerFill,
        onError: colors.onPrimary,
        surface: colors.surface,
        onSurface: colors.textPrimary,
      ),
      extensions: [colors],
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: CmpSpacing.borderCard,
          side: BorderSide(color: colors.outline),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: CmpTypography.headline.copyWith(
          color: colors.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CmpTypography.caption.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            );
          }
          return CmpTypography.caption.copyWith(color: colors.textSecondary);
        }),
      ),
    );
  }
}
