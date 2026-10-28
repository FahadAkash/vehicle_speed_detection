import 'dart:math' as math;

/// Pure-Dart Haversine Geodesic Distance Calculator.
/// Reference: AGENT.md Section 5 Rule 2 & Section 6.2.
/// ZERO Flutter/UI imports for 100% testability.
abstract final class HaversineCalculator {
  /// Earth's mean radius in meters.
  static const double earthRadiusM = 6371000.0;

  /// Computes geodesic distance in meters between two lat/long points (WGS84).
  static double distanceMeters({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final phi1 = _degToRad(lat1);
    final phi2 = _degToRad(lat2);
    final deltaPhi = _degToRad(lat2 - lat1);
    final deltaLambda = _degToRad(lon2 - lon1);

    final sinHalfDeltaPhi = math.sin(deltaPhi / 2.0);
    final sinHalfDeltaLambda = math.sin(deltaLambda / 2.0);

    final a =
        (sinHalfDeltaPhi * sinHalfDeltaPhi) +
        (math.cos(phi1) *
            math.cos(phi2) *
            sinHalfDeltaLambda *
            sinHalfDeltaLambda);

    final c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(math.max(0.0, 1.0 - a)));
    return earthRadiusM * c;
  }

  static double _degToRad(double deg) => deg * (math.pi / 180.0);
}
