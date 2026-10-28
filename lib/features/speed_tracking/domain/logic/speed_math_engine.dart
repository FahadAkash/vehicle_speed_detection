import 'package:vehicle_speed_estimator/core/constants/app_constants.dart';
import 'package:vehicle_speed_estimator/core/utils/geometry_utils.dart';
import 'package:vehicle_speed_estimator/core/utils/subframe_interpolator.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/tracked_vehicle_state.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/verified_speed_record.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/virtual_gate.dart';

/// Pure-Dart Zero-Fault Speed Mathematics and Gate Crossing Engine.
/// Reference: AGENT.md Section 5 Rule 3 & Rule 5.
class SpeedMathEngine {
  int rejectedFaultCount = 0;

  /// Detects gate crossing between previous and current ground-contact points.
  /// If crossed, computes microsecond timestamp with sub-frame interpolation.
  int? checkGateCrossing({
    required Vec2 prevPoint,
    required Vec2 currPoint,
    required int prevTimeUs,
    required int currTimeUs,
    required VirtualGate gate,
  }) {
    final intersection = GeometryUtils.findSegmentIntersection(
      prevPoint,
      currPoint,
      gate.p1,
      gate.p2,
    );

    if (intersection == null) return null;

    return SubframeInterpolator.interpolateCrossingTimeUs(
      prevTimeUs: prevTimeUs,
      currTimeUs: currTimeUs,
      pPrev: prevPoint,
      pCurr: currPoint,
      intersection: intersection,
    );
  }

  /// Evaluates 3-gate consistency and physics bounds on a tracked vehicle.
  /// Returns VerifiedSpeedRecord if all 4 checks pass; returns null otherwise.
  VerifiedSpeedRecord? evaluateSpeedRecord({
    required TrackedVehicleState track,
    required double distanceM,
    required double maxGyroObserved,
    required int timestampUtcMs,
    String siteName = '',
    double? speedLimitKmh,
    double consistencyTolerance = AppConstants.consistencyTolerance,
  }) {
    final tA = track.gateATimeUs;
    final tM = track.gateMTimeUs;
    final tB = track.gateBTimeUs;

    // Check 1: All three gate timestamps must exist
    if (tA == null || tM == null || tB == null) return null;

    // Check 2: Sequential crossing order (A->M->B or B->M->A)
    final String direction;
    final int dtHalf1Us;
    final int dtHalf2Us;
    final int dtTotalUs;

    if (tA < tM && tM < tB) {
      direction = 'A_TO_B';
      dtHalf1Us = tM - tA;
      dtHalf2Us = tB - tM;
      dtTotalUs = tB - tA;
    } else if (tB < tM && tM < tA) {
      direction = 'B_TO_A';
      dtHalf1Us = tM - tB;
      dtHalf2Us = tA - tM;
      dtTotalUs = tA - tB;
    } else {
      // Disordered gate crossing
      rejectedFaultCount++;
      return null;
    }

    if (dtHalf1Us <= 0 || dtHalf2Us <= 0 || dtTotalUs <= 0) {
      rejectedFaultCount++;
      return null;
    }

    final dtHalf1Sec = dtHalf1Us / 1000000.0;
    final dtHalf2Sec = dtHalf2Us / 1000000.0;
    final dtTotalSec = dtTotalUs / 1000000.0;

    final halfDistM = distanceM / 2.0;
    final v1Kmh = (halfDistM / dtHalf1Sec) * 3.6;
    final v2Kmh = (halfDistM / dtHalf2Sec) * 3.6;
    final vTotalKmh = (distanceM / dtTotalSec) * 3.6;

    // Check 3: Half-speed consistency check (|V1 - V2| / V_total <= 0.35)
    final divergence = (v1Kmh - v2Kmh).abs() / vTotalKmh;
    if (divergence > consistencyTolerance) {
      rejectedFaultCount++;
      return null;
    }

    // Check 4: Physical bounds check (5.0 km/h <= V_total <= 220.0 km/h)
    if (vTotalKmh < AppConstants.minSpeedKmh ||
        vTotalKmh > AppConstants.maxSpeedKmh) {
      rejectedFaultCount++;
      return null;
    }

    // Check 5: Gyroscope angular velocity must stay < 0.15 rad/s
    if (maxGyroObserved >= AppConstants.maxGyroRadPerSec) {
      rejectedFaultCount++;
      return null;
    }

    return VerifiedSpeedRecord(
      trackId: track.trackId,
      vehicleClass: track.vehicleClass,
      speedKmh: vTotalKmh,
      speedHalf1Kmh: v1Kmh,
      speedHalf2Kmh: v2Kmh,
      direction: direction,
      distanceM: distanceM,
      timestampUtcMs: timestampUtcMs,
      siteName: siteName,
      speedLimitKmh: speedLimitKmh,
    );
  }
}
