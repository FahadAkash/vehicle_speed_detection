import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_speed_estimator/core/constants/vehicle_classes.dart';
import 'package:vehicle_speed_estimator/core/utils/geometry_utils.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/logic/robust_vehicle_tracker.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/logic/speed_math_engine.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/virtual_gate.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/yolo_detection.dart';

void main() {
  group('Speed Accuracy & Zero-Fault Benchmark', () {
    final mathEngine = SpeedMathEngine();

    test('Benchmark accuracy across speeds 20 km/h to 120 km/h at 30 FPS over 30m', () {
      const distanceM = 30.0;
      const fps = 30;
      const frameDeltaUs = 1000000 ~/ fps; // 33,333 us

      const gateA = VirtualGate(
        name: 'Gate A',
        p1: Vec2(0.20, 0.0),
        p2: Vec2(0.20, 1.0),
      );
      const gateB = VirtualGate(
        name: 'Gate B',
        p1: Vec2(0.80, 0.0),
        p2: Vec2(0.80, 1.0),
      );
      final gateM = VirtualGate.generateMidpointGate(gateA, gateB);
      final gates = [gateA, gateM, gateB];

      final unitHistogram = List<double>.filled(24, 1.0 / math.sqrt(24.0));
      final targetSpeedsKmh = [25.0, 40.0, 50.0, 60.0, 75.0, 90.0, 110.0];
      final errors = <double>[];

      for (final groundTruthKmh in targetSpeedsKmh) {
        final tracker = RobustVehicleTracker();
        final speedMs = groundTruthKmh / 3.6;

        // Normalized gate span = 0.60 corresponds to 30.0 meters
        const gateSpanNorm = 0.60;
        const unitsPerMeter = gateSpanNorm / distanceM;
        final normVelocityPerSec = speedMs * unitsPerMeter;
        final normVelocityPerUs = normVelocityPerSec / 1000000.0;

        double currentX = 0.05;
        int currentUs = 1000000;
        double? verifiedSpeed;

        while (currentX < 0.95) {
          final det = YoloDetection(
            vehicleClass: VehicleClass.car,
            confidence: 0.90,
            left: currentX,
            top: 0.40,
            right: currentX + 0.10,
            bottom: 0.60,
            histogram: unitHistogram,
          );

          final verified = tracker.processFrame(
            detections: [det],
            frameTimeUs: currentUs,
            gates: gates,
            mathEngine: mathEngine,
            distanceM: distanceM,
            currentGyro: 0.01,
            currentUtcMs: 1700000000000,
          );

          if (verified.isNotEmpty) {
            verifiedSpeed = verified.first.speedKmh;
          }

          currentX += normVelocityPerUs * frameDeltaUs;
          currentUs += frameDeltaUs;
        }

        expect(verifiedSpeed, isNotNull,
            reason: 'Vehicle at $groundTruthKmh km/h should be verified');
        final error = (verifiedSpeed! - groundTruthKmh).abs();
        final percentAccuracy = (1.0 - (error / groundTruthKmh)) * 100;
        errors.add(error);

        // Sub-frame linear interpolation error should be < 0.5 km/h
        expect(error, lessThan(0.50),
            reason: 'Speed $groundTruthKmh km/h had error $error km/h (Accuracy: ${percentAccuracy.toStringAsFixed(2)}%)');
      }

      final avgError = errors.reduce((a, b) => a + b) / errors.length;
      expect(avgError, lessThan(0.30));
    });
  });
}
