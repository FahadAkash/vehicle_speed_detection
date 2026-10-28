import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_speed_estimator/core/constants/vehicle_classes.dart';
import 'package:vehicle_speed_estimator/core/utils/geometry_utils.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/logic/speed_math_engine.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/tracked_vehicle_state.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/virtual_gate.dart';

void main() {
  group('SpeedMathEngine', () {
    late SpeedMathEngine engine;

    setUp(() {
      engine = SpeedMathEngine();
    });

    test(
      'detects gate crossing and interpolates sub-frame timestamp accurately',
      () {
        const gate = VirtualGate(
          name: 'Gate A',
          p1: Vec2(0.5, 0.0),
          p2: Vec2(0.5, 1.0),
        );

        // Vehicle moving from x=0.4 to x=0.6 across gate at x=0.5
        // Midpoint is exactly at 50% of the movement
        const pPrev = Vec2(0.4, 0.5);
        const pCurr = Vec2(0.6, 0.5);
        const tPrevUs = 1000000;
        const tCurrUs = 1033333; // ~33.3ms later

        final crossingUs = engine.checkGateCrossing(
          prevPoint: pPrev,
          currPoint: pCurr,
          prevTimeUs: tPrevUs,
          currTimeUs: tCurrUs,
          gate: gate,
        );

        expect(crossingUs, isNotNull);
        // Crossing is at exact midpoint: 1000000 + 33333 / 2 = 1016666
        expect(crossingUs!, closeTo(1016666, 5));
      },
    );

    test('returns null when vehicle does not cross gate', () {
      const gate = VirtualGate(
        name: 'Gate A',
        p1: Vec2(0.5, 0.0),
        p2: Vec2(0.5, 1.0),
      );

      // Movement entirely to the left of gate
      const pPrev = Vec2(0.2, 0.5);
      const pCurr = Vec2(0.3, 0.5);

      final crossingUs = engine.checkGateCrossing(
        prevPoint: pPrev,
        currPoint: pCurr,
        prevTimeUs: 1000000,
        currTimeUs: 1033333,
        gate: gate,
      );

      expect(crossingUs, isNull);
    });

    test('validates consistent 3-gate speed within physical bounds', () {
      // 30m distance, 60 km/h (16.6667 m/s) -> 1.8 seconds total
      // 0.9s per half (900,000 us)
      const track = TrackedVehicleState(
        trackId: 101,
        vehicleClass: VehicleClass.car,
        left: 0.1,
        top: 0.2,
        right: 0.3,
        bottom: 0.4,
        vx: 0.1,
        vy: 0.0,
        colorHistogram: [],
        lastSeenTimeUs: 2800000,
        gateATimeUs: 1000000,
        gateMTimeUs: 1900000,
        gateBTimeUs: 2800000,
      );

      final record = engine.evaluateSpeedRecord(
        track: track,
        distanceM: 30.0,
        maxGyroObserved: 0.02,
        timestampUtcMs: 1700000000000,
      );

      expect(record, isNotNull);
      expect(record!.speedKmh, closeTo(60.0, 0.5));
      expect(record.direction, equals('A_TO_B'));
      expect(engine.rejectedFaultCount, equals(0));
    });

    test('rejects inconsistent speed (V1=40, V2=110) silently and increments rejectedFaultCount', () {
      // V1 = (15m / 1.35s) * 3.6 = 40.0 km/h -> dt1 = 1,350,000 us
      // V2 = (15m / 0.4909s) * 3.6 = 110.0 km/h -> dt2 = 490,909 us
      const tA = 1000000;
      const tM = tA + 1350000;
      const tB = tM + 490909;

      const track = TrackedVehicleState(
        trackId: 102,
        vehicleClass: VehicleClass.truck,
        left: 0.1,
        top: 0.2,
        right: 0.3,
        bottom: 0.4,
        vx: 0.1,
        vy: 0.0,
        colorHistogram: [],
        lastSeenTimeUs: tB,
        gateATimeUs: tA,
        gateMTimeUs: tM,
        gateBTimeUs: tB,
      );

      final record = engine.evaluateSpeedRecord(
        track: track,
        distanceM: 30.0,
        maxGyroObserved: 0.01,
        timestampUtcMs: 1700000000000,
      );

      expect(record, isNull);
      expect(engine.rejectedFaultCount, equals(1));
    });

    test('rejects speed when camera gyro exceeded limit', () {
      const track = TrackedVehicleState(
        trackId: 103,
        vehicleClass: VehicleClass.cng,
        left: 0.1,
        top: 0.2,
        right: 0.3,
        bottom: 0.4,
        vx: 0.1,
        vy: 0.0,
        colorHistogram: [],
        lastSeenTimeUs: 2800000,
        gateATimeUs: 1000000,
        gateMTimeUs: 1900000,
        gateBTimeUs: 2800000,
      );

      final record = engine.evaluateSpeedRecord(
        track: track,
        distanceM: 30.0,
        maxGyroObserved: 0.25, // Exceeds 0.15 rad/s
        timestampUtcMs: 1700000000000,
      );

      expect(record, isNull);
      expect(engine.rejectedFaultCount, equals(1));
    });
  });
}
