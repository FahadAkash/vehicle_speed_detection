import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_speed_estimator/core/constants/app_constants.dart';
import 'package:vehicle_speed_estimator/core/constants/vehicle_classes.dart';
import 'package:vehicle_speed_estimator/core/utils/geometry_utils.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/logic/robust_vehicle_tracker.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/logic/speed_math_engine.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/virtual_gate.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/yolo_detection.dart';

void main() {
  group('RobustVehicleTracker (4-Layer Defense)', () {
    late RobustVehicleTracker tracker;
    late SpeedMathEngine mathEngine;
    late List<VirtualGate> gates;

    setUp(() {
      tracker = RobustVehicleTracker();
      mathEngine = SpeedMathEngine();

      const gateA = VirtualGate(
        name: 'Gate A',
        p1: Vec2(0.2, 0.0),
        p2: Vec2(0.2, 1.0),
      );
      const gateB = VirtualGate(
        name: 'Gate B',
        p1: Vec2(0.8, 0.0),
        p2: Vec2(0.8, 1.0),
      );
      final gateM = VirtualGate.generateMidpointGate(gateA, gateB);
      gates = [gateA, gateM, gateB];
    });

    test('Two differently colored cars side-by-side maintain 0 ID swaps via color histogram lock', () {
      // Car 1 (Red car) histogram: high in red bins (0..7)
      final redHist = List<double>.filled(24, 0.0)..[0] = 1.0;
      // Car 2 (Blue car) histogram: high in blue bins (16..23)
      final blueHist = List<double>.filled(24, 0.0)..[16] = 1.0;

      // Frame 1: Car 1 at Lane 1 (y=0.2), Car 2 at Lane 2 (y=0.6)
      tracker.processFrame(
        detections: [
          YoloDetection(
            vehicleClass: VehicleClass.car,
            confidence: 0.85,
            left: 0.05,
            top: 0.15,
            right: 0.15,
            bottom: 0.25,
            histogram: redHist,
          ),
          YoloDetection(
            vehicleClass: VehicleClass.car,
            confidence: 0.85,
            left: 0.05,
            top: 0.55,
            right: 0.15,
            bottom: 0.65,
            histogram: blueHist,
          ),
        ],
        frameTimeUs: 1000000,
        gates: gates,
        mathEngine: mathEngine,
        distanceM: 30.0,
        currentGyro: 0.01,
        currentUtcMs: 1700000000000,
      );

      expect(tracker.activeTracks.length, equals(2));
      final track1Id = tracker.activeTracks[0].trackId;
      final track2Id = tracker.activeTracks[1].trackId;

      // Frame 2: They move forward, slightly close in IoU, but colors are distinct
      tracker.processFrame(
        detections: [
          YoloDetection(
            vehicleClass: VehicleClass.car,
            confidence: 0.85,
            left: 0.10,
            top: 0.15,
            right: 0.20,
            bottom: 0.25,
            histogram: redHist,
          ),
          YoloDetection(
            vehicleClass: VehicleClass.car,
            confidence: 0.85,
            left: 0.10,
            top: 0.55,
            right: 0.20,
            bottom: 0.65,
            histogram: blueHist,
          ),
        ],
        frameTimeUs: 1033333,
        gates: gates,
        mathEngine: mathEngine,
        distanceM: 30.0,
        currentGyro: 0.01,
        currentUtcMs: 1700000000033,
      );

      final car1 = tracker.activeTracks.firstWhere((t) => t.top < 0.3);
      final car2 = tracker.activeTracks.firstWhere((t) => t.top > 0.5);

      expect(car1.trackId, equals(track1Id));
      expect(car2.trackId, equals(track2Id));
    });

    test('Car occluded by bus for 10 frames preserves trackId via ByteTrack coasting', () {
      final redHist = List<double>.filled(24, 0.0)..[0] = 1.0;

      // Frame 1: Car detected
      tracker.processFrame(
        detections: [
          YoloDetection(
            vehicleClass: VehicleClass.car,
            confidence: 0.90,
            left: 0.10,
            top: 0.20,
            right: 0.25,
            bottom: 0.35,
            histogram: redHist,
          ),
        ],
        frameTimeUs: 1000000,
        gates: gates,
        mathEngine: mathEngine,
        distanceM: 30.0,
        currentGyro: 0.01,
        currentUtcMs: 1700000000000,
      );

      final originalTrackId = tracker.activeTracks.first.trackId;

      // Simulate 10 frames of occlusion: empty detections (or only bus detected elsewhere)
      int timeUs = 1000000;
      for (int i = 1; i <= 10; i++) {
        timeUs += 33333;
        tracker.processFrame(
          detections: [],
          frameTimeUs: timeUs,
          gates: gates,
          mathEngine: mathEngine,
          distanceM: 30.0,
          currentGyro: 0.01,
          currentUtcMs: 1700000000000 + (i * 33),
        );
      }

      // Track should still be active with coastFrames = 10
      expect(tracker.activeTracks.length, equals(1));
      expect(tracker.activeTracks.first.trackId, equals(originalTrackId));
      expect(tracker.activeTracks.first.coastFrames, equals(10));
      expect(
        tracker.activeTracks.first.coastFrames,
        lessThanOrEqualTo(AppConstants.maxCoastFrames),
      );

      // Frame 12: Vehicle re-appears with low confidence (partially occluded)
      timeUs += 33333;
      tracker.processFrame(
        detections: [
          YoloDetection(
            vehicleClass: VehicleClass.car,
            confidence: 0.35, // Low confidence ByteTrack recovery
            left: tracker.activeTracks.first.left,
            top: tracker.activeTracks.first.top,
            right: tracker.activeTracks.first.right,
            bottom: tracker.activeTracks.first.bottom,
            histogram: redHist,
          ),
        ],
        frameTimeUs: timeUs,
        gates: gates,
        mathEngine: mathEngine,
        distanceM: 30.0,
        currentGyro: 0.01,
        currentUtcMs: 1700000000400,
      );

      // Track recovered, coastFrames reset to 0, trackId preserved!
      expect(tracker.activeTracks.first.trackId, equals(originalTrackId));
      expect(tracker.activeTracks.first.coastFrames, equals(0));
    });
  });
}
