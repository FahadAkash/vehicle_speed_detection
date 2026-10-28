import 'package:flutter/material.dart';

/// Spacing, radius, and elevation tokens.
/// Reference: AGENT.md Section 7.6.
abstract final class CmpSpacing {
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  static const double radiusCard = 12.0;
  static const double radiusSheet = 16.0;
  static const double radiusPill = 999.0;

  static const double minTouchTarget = 48.0;
  static const double primaryButtonHeight = 56.0;
  static const double liveActionHeight = 64.0;

  static const BorderRadius borderCard = BorderRadius.all(
    Radius.circular(radiusCard),
  );
  static const BorderRadius borderSheet = BorderRadius.all(
    Radius.circular(radiusSheet),
  );
  static const BorderRadius borderPill = BorderRadius.all(
    Radius.circular(radiusPill),
  );
}
