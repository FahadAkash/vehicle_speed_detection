import 'dart:async';
import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';
import 'package:vehicle_speed_estimator/core/constants/app_constants.dart';

/// Monitors device motion & tripod stability using gyroscope events.
/// Reference: AGENT.md Section 4 & Section 5 Rule 5.
class SensorsService {
  StreamSubscription<GyroscopeEvent>? _sub;
  double _currentAngularVelocity = 0.0;
  bool _isSteady = true;

  final _stabilityController = StreamController<bool>.broadcast();
  Stream<bool> get isSteadyStream => _stabilityController.stream;

  double get currentAngularVelocity => _currentAngularVelocity;
  bool get isSteady => _isSteady;

  void startListening() {
    _sub = gyroscopeEventStream().listen((event) {
      final radPerSec = math.sqrt(
        (event.x * event.x) + (event.y * event.y) + (event.z * event.z),
      );
      _currentAngularVelocity = radPerSec;
      final steadyNow = radPerSec < AppConstants.maxGyroRadPerSec;

      if (steadyNow != _isSteady) {
        _isSteady = steadyNow;
        _stabilityController.add(_isSteady);
      }
    });
  }

  void stopListening() {
    _sub?.cancel();
    _sub = null;
    _stabilityController.close();
  }
}
