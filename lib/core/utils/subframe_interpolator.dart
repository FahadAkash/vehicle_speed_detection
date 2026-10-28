import 'package:vehicle_speed_estimator/core/utils/geometry_utils.dart';

/// Pure-Dart sub-frame microsecond interpolator.
/// Reference: AGENT.md Section 5 Rule 3.
abstract final class SubframeInterpolator {
  /// Computes sub-frame crossing timestamp in microseconds.
  /// Formula: t_cross = t_prev + (t_curr - t_prev) * (dist(P_prev, Intersection) / dist(P_prev, P_curr))
  static int interpolateCrossingTimeUs({
    required int prevTimeUs,
    required int currTimeUs,
    required Vec2 pPrev,
    required Vec2 pCurr,
    required Vec2 intersection,
  }) {
    final totalDist = pPrev.distanceTo(pCurr);
    if (totalDist < 1e-6) return currTimeUs;

    final distToGate = pPrev.distanceTo(intersection);
    final ratio = (distToGate / totalDist).clamp(0.0, 1.0);

    final deltaUs = currTimeUs - prevTimeUs;
    return prevTimeUs + (deltaUs * ratio).round();
  }
}
