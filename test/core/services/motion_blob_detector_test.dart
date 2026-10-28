import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_speed_estimator/core/services/motion_blob_detector.dart';

void main() {
  group('MotionBlobDetector Tests', () {
    const detector = MotionBlobDetector();
    const gw = MotionBlobDetector.gridW;
    const gh = MotionBlobDetector.gridH;

    test('returns empty when prevGrid is null', () {
      final curr = Uint8List(gw * gh);
      final detections = detector.detectVehicles(curr, null);
      expect(detections, isEmpty);
    });

    test('detects single moving car and produces unit-normalized histogram', () {
      final prev = Uint8List(gw * gh);
      final curr = Uint8List(gw * gh);

      // Simulate a car moving into rows 10..18, cols 12..18
      for (int gy = 10; gy <= 18; gy++) {
        for (int gx = 12; gx <= 18; gx++) {
          curr[gy * gw + gx] = 200; // Bright car
        }
      }

      final detections = detector.detectVehicles(curr, prev);
      expect(detections.length, 1);
      final car = detections.first;

      // Verify bounding box location
      expect(car.left, lessThan(12.0 / gw));
      expect(car.right, greaterThan(18.0 / gw));
      expect(car.top, lessThanOrEqualTo(10.0 / gh));
      expect(car.bottom, greaterThanOrEqualTo(18.0 / gh));

      // Verify unit-normalized histogram
      double sumSq = 0.0;
      for (final h in car.histogram) {
        sumSq += h * h;
      }
      expect(math.sqrt(sumSq), closeTo(1.0, 0.01));
    });

    test('segments multiple vehicles moving simultaneously', () {
      final prev = Uint8List(gw * gh);
      final curr = Uint8List(gw * gh);

      // Vehicle 1: left lane (cols 6..11, rows 12..18)
      for (int gy = 12; gy <= 18; gy++) {
        for (int gx = 6; gx <= 11; gx++) {
          curr[gy * gw + gx] = 180;
        }
      }

      // Vehicle 2: right lane (cols 32..38, rows 14..22)
      for (int gy = 14; gy <= 22; gy++) {
        for (int gx = 32; gx <= 38; gx++) {
          curr[gy * gw + gx] = 220;
        }
      }

      final detections = detector.detectVehicles(curr, prev);
      expect(detections.length, 2);

      final v1 = detections.firstWhere((d) => d.centerX < 0.5);
      final v2 = detections.firstWhere((d) => d.centerX > 0.5);

      expect(v1.centerX, closeTo((6 + 11) / 2.0 / gw, 0.1));
      expect(v2.centerX, closeTo((32 + 38) / 2.0 / gw, 0.1));
    });
  });
}

