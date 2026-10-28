import 'package:vehicle_speed_estimator/core/constants/vehicle_classes.dart';
import 'package:vehicle_speed_estimator/core/utils/geometry_utils.dart';

/// State of an active vehicle track in the background Isolate.
/// Reference: AGENT.md Section 5 Rule 4.
class TrackedVehicleState {
  const TrackedVehicleState({
    required this.trackId,
    required this.vehicleClass,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.vx,
    required this.vy,
    required this.colorHistogram,
    required this.lastSeenTimeUs,
    this.firstSeenTimeUs = 0,
    this.gateATimeUs,
    this.gateMTimeUs,
    this.gateBTimeUs,
    this.coastFrames = 0,
    this.isVerified = false,
    this.verifiedSpeedKmh,
    this.verifiedDirection,
    this.prevGroundContact,
  });

  final int trackId;
  final VehicleClass vehicleClass;
  final double left;
  final double top;
  final double right;
  final double bottom;
  final double vx; // Normalized change in X per second
  final double vy; // Normalized change in Y per second
  final List<double> colorHistogram;
  final int firstSeenTimeUs;
  final int lastSeenTimeUs;
  final int? gateATimeUs;
  final int? gateMTimeUs;
  final int? gateBTimeUs;
  final int coastFrames;
  final bool isVerified;
  final double? verifiedSpeedKmh;
  final String? verifiedDirection;
  final Vec2? prevGroundContact;

  double get width => right - left;
  double get height => bottom - top;
  double get centerX => left + (width / 2.0);
  double get centerY => top + (height / 2.0);
  Vec2 get groundContactPoint => Vec2(centerX, bottom);

  /// Predicts bounding box at a new timestamp using constant-velocity kinematics.
  (double pLeft, double pTop, double pRight, double pBottom) predictBoxAt(
    int targetTimeUs,
  ) {
    final dtSeconds = (targetTimeUs - lastSeenTimeUs) / 1000000.0;
    final dx = vx * dtSeconds;
    final dy = vy * dtSeconds;
    return (
      (left + dx).clamp(0.0, 1.0),
      (top + dy).clamp(0.0, 1.0),
      (right + dx).clamp(0.0, 1.0),
      (bottom + dy).clamp(0.0, 1.0),
    );
  }

  TrackedVehicleState copyWith({
    int? trackId,
    VehicleClass? vehicleClass,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? vx,
    double? vy,
    List<double>? colorHistogram,
    int? firstSeenTimeUs,
    int? lastSeenTimeUs,
    int? gateATimeUs,
    int? gateMTimeUs,
    int? gateBTimeUs,
    int? coastFrames,
    bool? isVerified,
    double? verifiedSpeedKmh,
    String? verifiedDirection,
    Vec2? prevGroundContact,
  }) {
    return TrackedVehicleState(
      trackId: trackId ?? this.trackId,
      vehicleClass: vehicleClass ?? this.vehicleClass,
      left: left ?? this.left,
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
      vx: vx ?? this.vx,
      vy: vy ?? this.vy,
      colorHistogram: colorHistogram ?? this.colorHistogram,
      firstSeenTimeUs: firstSeenTimeUs ?? this.firstSeenTimeUs,
      lastSeenTimeUs: lastSeenTimeUs ?? this.lastSeenTimeUs,
      gateATimeUs: gateATimeUs ?? this.gateATimeUs,
      gateMTimeUs: gateMTimeUs ?? this.gateMTimeUs,
      gateBTimeUs: gateBTimeUs ?? this.gateBTimeUs,
      coastFrames: coastFrames ?? this.coastFrames,
      isVerified: isVerified ?? this.isVerified,
      verifiedSpeedKmh: verifiedSpeedKmh ?? this.verifiedSpeedKmh,
      verifiedDirection: verifiedDirection ?? this.verifiedDirection,
      prevGroundContact: prevGroundContact ?? this.prevGroundContact,
    );
  }
}
