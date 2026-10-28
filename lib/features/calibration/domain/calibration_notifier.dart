import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_speed_estimator/core/utils/geometry_utils.dart';
import 'package:vehicle_speed_estimator/core/utils/haversine_calculator.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/calibration_config.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/virtual_gate.dart';

class CalibrationState {
  const CalibrationState({
    this.config = const CalibrationConfig(
      distanceM: 0.0,
      method: CalibrationMethod.satellite,
    ),
    this.gateA,
    this.gateB,
    this.gateM,
    this.isSteady = true,
    this.currentGyro = 0.0,
  });

  final CalibrationConfig config;
  final VirtualGate? gateA;
  final VirtualGate? gateB;
  final VirtualGate? gateM;
  final bool isSteady;
  final double currentGyro;

  List<VirtualGate> get gates => [
        if (gateA != null) gateA!,
        if (gateM != null) gateM!,
        if (gateB != null) gateB!,
      ];

  bool get isCalibrationValid => config.isValid;
  bool get areGatesConfirmed => gateA != null && gateB != null && gateM != null;

  CalibrationState copyWith({
    CalibrationConfig? config,
    VirtualGate? gateA,
    VirtualGate? gateB,
    VirtualGate? gateM,
    bool? isSteady,
    double? currentGyro,
  }) {
    return CalibrationState(
      config: config ?? this.config,
      gateA: gateA ?? this.gateA,
      gateB: gateB ?? this.gateB,
      gateM: gateM ?? this.gateM,
      isSteady: isSteady ?? this.isSteady,
      currentGyro: currentGyro ?? this.currentGyro,
    );
  }
}

class CalibrationNotifier extends Notifier<CalibrationState> {
  @override
  CalibrationState build() => const CalibrationState();

  void updateSessionParams({
    required String siteName,
    double? speedLimitKmh,
    required bool isTwoWay,
  }) {
    state = state.copyWith(
      config: state.config.copyWith(
        siteName: siteName,
        speedLimitKmh: speedLimitKmh,
        isTwoWay: isTwoWay,
      ),
    );
  }

  void setSatellitePins({
    required double latA,
    required double lonA,
    required double latB,
    required double lonB,
  }) {
    final dist = HaversineCalculator.distanceMeters(
      lat1: latA,
      lon1: lonA,
      lat2: latB,
      lon2: lonB,
    );

    state = state.copyWith(
      config: state.config.copyWith(
        distanceM: dist,
        method: CalibrationMethod.satellite,
        pinALat: latA,
        pinALon: lonA,
        pinBLat: latB,
        pinBLon: lonB,
      ),
    );
  }

  void setFallbackDistance(double distanceM) {
    state = state.copyWith(
      config: state.config.copyWith(
        distanceM: distanceM,
        method: CalibrationMethod.fallbackTilt,
      ),
    );
  }

  void setGates(VirtualGate a, VirtualGate b) {
    final m = VirtualGate.generateMidpointGate(a, b);
    state = state.copyWith(gateA: a, gateB: b, gateM: m);
  }

  void resetGates() {
    // Default initial gate layout
    const a = VirtualGate(
      name: 'Gate A',
      p1: Vec2(0.25, 0.1),
      p2: Vec2(0.25, 0.9),
    );
    const b = VirtualGate(
      name: 'Gate B',
      p1: Vec2(0.75, 0.1),
      p2: Vec2(0.75, 0.9),
    );
    final m = VirtualGate.generateMidpointGate(a, b);
    state = state.copyWith(gateA: a, gateB: b, gateM: m);
  }

  void setSteady(bool steady) {
    state = state.copyWith(isSteady: steady);
  }
}

final calibrationNotifierProvider =
    NotifierProvider<CalibrationNotifier, CalibrationState>(
      CalibrationNotifier.new,
    );
