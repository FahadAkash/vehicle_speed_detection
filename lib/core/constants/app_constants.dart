/// Production constants for CMP Speed Monitor.
/// Reference: AGENT.md Section 4.
abstract final class AppConstants {
  /// Minimum allowed distance D between gates A and B in meters.
  static const double minGateDistanceM = 15.0;

  /// Recommended lower bound for distance D in meters.
  static const double recommendedGateDistanceMin = 20.0;

  /// Recommended upper bound for distance D in meters.
  static const double recommendedGateDistanceMax = 50.0;

  /// Map zoom level target for landmark pin-dropping.
  static const double satelliteZoomTarget = 20.0;

  /// Stage-1 (high-confidence) detection threshold.
  static const double highConfThreshold = 0.50;

  /// Stage-2 (ByteTrack) lower bound confidence threshold.
  static const double lowConfThreshold = 0.15;

  /// Number of histogram bins per RGB channel.
  static const int colorHistBins = 8;

  /// Ratio defining the inner core of bounding box for color extraction.
  static const double colorHistCoreRatio = 0.50;

  /// Minimum cosine similarity to accept color histogram match.
  static const double colorSimilarityMin = 0.65;

  /// Maximum frames an unmatched track may coast before deletion.
  static const int maxCoastFrames = 15;

  /// Maximum allowed speed divergence between half-spans (|V1 - V2| / V_total).
  static const double consistencyTolerance = 0.35;

  /// Lower physical speed limit bound in km/h.
  static const double minSpeedKmh = 5.0;

  /// Upper physical speed limit bound in km/h.
  static const double maxSpeedKmh = 220.0;

  /// Maximum allowed camera angular velocity (rad/s) during tracking.
  static const double maxGyroRadPerSec = 0.15;

  /// Fallback map center coordinates (Chattogram, Bangladesh).
  static const double defaultMapCenterLatitude = 22.3569;
  static const double defaultMapCenterLongitude = 91.7832;

  /// Maximum update rate of numeric HUD metrics in Hz.
  static const int hudMetricsMaxHz = 4;

  /// Duration in milliseconds an on-video verified speed chip stays visible.
  static const int speedChipHoldMs = 2500;
}
