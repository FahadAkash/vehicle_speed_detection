import 'package:flutter/material.dart';

/// Typography definitions for CMP Speed Monitor.
/// Reference: AGENT.md Section 7.5.
abstract final class CmpTypography {
  static const String fontPrimary = 'Inter';
  static const List<String> fontFallbacks = [
    'NotoSansBengali',
    'Inter',
    'Roboto',
    'sans-serif',
  ];

  static const TextStyle speedDisplay = TextStyle(
    fontFamily: fontPrimary,
    fontFamilyFallback: fontFallbacks,
    fontSize: 40.0,
    fontWeight: FontWeight.w700,
    height: 1.4,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle headline = TextStyle(
    fontFamily: fontPrimary,
    fontFamilyFallback: fontFallbacks,
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontPrimary,
    fontFamilyFallback: fontFallbacks,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontPrimary,
    fontFamilyFallback: fontFallbacks,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontPrimary,
    fontFamilyFallback: fontFallbacks,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontPrimary,
    fontFamilyFallback: fontFallbacks,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  /// Tabular variation of any text style for numbers and live metrics.
  static TextStyle tabular(TextStyle base) =>
      base.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}
