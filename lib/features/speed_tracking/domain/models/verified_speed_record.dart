import 'package:vehicle_speed_estimator/core/constants/vehicle_classes.dart';

/// Immutable verified speed record compliant with CMP telemetry shape.
/// Reference: AGENT.md Section 5 Rule 6.
class VerifiedSpeedRecord {
  const VerifiedSpeedRecord({
    required this.trackId,
    required this.vehicleClass,
    required this.speedKmh,
    required this.speedHalf1Kmh,
    required this.speedHalf2Kmh,
    required this.direction,
    required this.distanceM,
    required this.timestampUtcMs,
    this.siteName = '',
    this.speedLimitKmh,
    this.isSynced = false,
  });

  final int trackId;
  final VehicleClass vehicleClass;
  final double speedKmh;
  final double speedHalf1Kmh;
  final double speedHalf2Kmh;
  final String direction; // 'A_TO_B' or 'B_TO_A'
  final double distanceM;
  final int timestampUtcMs;
  final String siteName;
  final double? speedLimitKmh;
  final bool isSynced;

  /// Returns true if speed exceeds session limit.
  bool get isOverLimit => speedLimitKmh != null && speedKmh > speedLimitKmh!;

  /// Divergence ratio between half speeds: |V1 - V2| / V_total.
  double get consistencyDivergence {
    if (speedKmh <= 0.0) return 1.0;
    return ((speedHalf1Kmh - speedHalf2Kmh).abs() / speedKmh);
  }

  Map<String, dynamic> toTelemetryJson() {
    return {
      'track_id': trackId,
      'vehicle_class': vehicleClass.wireName,
      'speed_kmh': double.parse(speedKmh.toStringAsFixed(2)),
      'speed_half1_kmh': double.parse(speedHalf1Kmh.toStringAsFixed(2)),
      'speed_half2_kmh': double.parse(speedHalf2Kmh.toStringAsFixed(2)),
      'direction': direction,
      'distance_m': double.parse(distanceM.toStringAsFixed(2)),
      'timestamp_utc_ms': timestampUtcMs,
    };
  }

  factory VerifiedSpeedRecord.fromJson(Map<String, dynamic> json) {
    return VerifiedSpeedRecord(
      trackId: json['track_id'] as int,
      vehicleClass: VehicleClass.fromString(json['vehicle_class'] as String),
      speedKmh: (json['speed_kmh'] as num).toDouble(),
      speedHalf1Kmh: (json['speed_half1_kmh'] as num).toDouble(),
      speedHalf2Kmh: (json['speed_half2_kmh'] as num).toDouble(),
      direction: json['direction'] as String,
      distanceM: (json['distance_m'] as num).toDouble(),
      timestampUtcMs: json['timestamp_utc_ms'] as int,
    );
  }

  VerifiedSpeedRecord copyWith({
    int? trackId,
    VehicleClass? vehicleClass,
    double? speedKmh,
    double? speedHalf1Kmh,
    double? speedHalf2Kmh,
    String? direction,
    double? distanceM,
    int? timestampUtcMs,
    String? siteName,
    double? speedLimitKmh,
    bool? isSynced,
  }) {
    return VerifiedSpeedRecord(
      trackId: trackId ?? this.trackId,
      vehicleClass: vehicleClass ?? this.vehicleClass,
      speedKmh: speedKmh ?? this.speedKmh,
      speedHalf1Kmh: speedHalf1Kmh ?? this.speedHalf1Kmh,
      speedHalf2Kmh: speedHalf2Kmh ?? this.speedHalf2Kmh,
      direction: direction ?? this.direction,
      distanceM: distanceM ?? this.distanceM,
      timestampUtcMs: timestampUtcMs ?? this.timestampUtcMs,
      siteName: siteName ?? this.siteName,
      speedLimitKmh: speedLimitKmh ?? this.speedLimitKmh,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
