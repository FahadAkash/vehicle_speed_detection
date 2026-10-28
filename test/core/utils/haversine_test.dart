import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_speed_estimator/core/utils/haversine_calculator.dart';

void main() {
  group('HaversineCalculator', () {
    test('computes distance between known GPS coordinates accurately', () {
      // Landmark A and B in Chattogram
      const lat1 = 22.356912;
      const lon1 = 91.783211;
      const lat2 = 22.357180;
      const lon2 = 91.783342;

      final distance = HaversineCalculator.distanceMeters(
        lat1: lat1,
        lon1: lon1,
        lat2: lat2,
        lon2: lon2,
      );

      // Distance should be ~32.7 meters
      expect(distance, greaterThan(32.0));
      expect(distance, lessThan(33.5));
    });

    test('returns zero distance for identical coordinates', () {
      final distance = HaversineCalculator.distanceMeters(
        lat1: 22.3569,
        lon1: 91.7832,
        lat2: 22.3569,
        lon2: 91.7832,
      );

      expect(distance, closeTo(0.0, 1e-4));
    });
  });
}
