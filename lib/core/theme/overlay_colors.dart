import 'package:flutter/material.dart';

/// Theme-independent overlay colors for live camera view.
/// Reference: AGENT.md Section 7.4.
abstract final class OverlayColors {
  /// Gate A (Start) - 3 dp solid line, round end handles.
  static const Color gateA = Color(0xFFFFED00);

  /// Gate M (Midpoint) - 2 dp dashed line, auto-generated.
  static const Color gateM = Color(0xFFFFFFFF);

  /// Gate B (End) - 3 dp solid line, round end handles.
  static const Color gateB = Color(0xFF2FD27A);

  /// Tracked vehicle box (85% white) - 2 dp, 6 dp corner radius.
  static const Color trackedBox = Color(0xD9FFFFFF);

  /// Verified vehicle box - 3 dp green.
  static const Color verifiedBox = Color(0xFF2FD27A);

  /// Over-speed limit vehicle box - 3 dp red.
  static const Color overLimitBox = Color(0xFFE30613);

  /// Solid translucent scrim for HUD panels on live camera preview (70% black, no blur).
  static const Color overlayScrim = Color(0xB3000000);

  /// 1 px shadow underlay for legibility.
  static const Color textShadow = Color(0xFF000000);
}
