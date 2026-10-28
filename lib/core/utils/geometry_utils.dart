import 'dart:math' as math;

/// Point representation for pure-Dart geometric operations.
class Vec2 {
  const Vec2(this.x, this.y);

  final double x;
  final double y;

  double distanceTo(Vec2 other) {
    final dx = other.x - x;
    final dy = other.y - y;
    return math.sqrt(dx * dx + dy * dy);
  }

  Vec2 lerp(Vec2 other, double t) {
    return Vec2(x + (other.x - x) * t, y + (other.y - y) * t);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Vec2 && other.x == x && other.y == y);

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Vec2($x, $y)';
}

/// Pure-Dart geometry helper for line intersections and distances.
/// Reference: AGENT.md Section 5 Rule 3.
abstract final class GeometryUtils {
  /// Computes intersection point of segment P1->P2 with segment G1->G2.
  /// Returns null if lines are parallel or intersection lies outside segments.
  static Vec2? findSegmentIntersection(Vec2 p1, Vec2 p2, Vec2 g1, Vec2 g2) {
    final dpx = p2.x - p1.x;
    final dpy = p2.y - p1.y;
    final dgx = g2.x - g1.x;
    final dgy = g2.y - g1.y;

    final denom = (dpx * dgy) - (dpy * dgx);
    if (denom.abs() < 1e-9) return null;

    final t = (((g1.x - p1.x) * dgy) - ((g1.y - p1.y) * dgx)) / denom;
    final u = (((g1.x - p1.x) * dpy) - ((g1.y - p1.y) * dpx)) / denom;

    if (t >= -0.01 && t <= 1.01 && u >= -0.01 && u <= 1.01) {
      final clampedT = t.clamp(0.0, 1.0);
      return Vec2(p1.x + (clampedT * dpx), p1.y + (clampedT * dpy));
    }
    return null;
  }
}
