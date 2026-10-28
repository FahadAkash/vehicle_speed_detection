import 'package:vehicle_speed_estimator/core/constants/app_constants.dart';

enum CalibrationMethod { satellite, fallbackTilt }

/// Represents the site calibration configuration.
/// Reference: AGENT.md Section 1, 4 & 8.
class CalibrationConfig {
  const CalibrationConfig({
    required this.distanceM,
    required this.method,
    this.pinALat,
    this.pinALon,
    this.pinBLat,
    this.pinBLon,
    this.siteName = '',
    this.speedLimitKmh,
    this.isTwoWay = false,
  });

  final double distanceM;
  final CalibrationMethod method;
  final double? pinALat;
  final double? pinALon;
  final double? pinBLat;
  final double? pinBLon;
  final String siteName;
  final double? speedLimitKmh;
  final bool isTwoWay;

  /// Returns true if distance meets minimum gate distance (15 m).
  bool get isValid => distanceM >= AppConstants.minGateDistanceM;

  CalibrationConfig copyWith({
    double? distanceM,
    CalibrationMethod? method,
    double? pinALat,
    double? pinALon,
    double? pinBLat,
    double? pinBLon,
    String? siteName,
    double? speedLimitKmh,
    bool? isTwoWay,
  }) {
    return CalibrationConfig(
      distanceM: distanceM ?? this.distanceM,
      method: method ?? this.method,
      pinALat: pinALat ?? this.pinALat,
      pinALon: pinALon ?? this.pinALon,
      pinBLat: pinBLat ?? this.pinBLat,
      pinBLon: pinBLon ?? this.pinBLon,
      siteName: siteName ?? this.siteName,
      speedLimitKmh: speedLimitKmh ?? this.speedLimitKmh,
      isTwoWay: isTwoWay ?? this.isTwoWay,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalibrationConfig &&
          other.distanceM == distanceM &&
          other.method == method &&
          other.siteName == siteName &&
          other.speedLimitKmh == speedLimitKmh &&
          other.isTwoWay == isTwoWay);

  @override
  int get hashCode =>
      Object.hash(distanceM, method, siteName, speedLimitKmh, isTwoWay);
}
