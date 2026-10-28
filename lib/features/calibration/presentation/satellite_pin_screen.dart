import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:vehicle_speed_estimator/core/constants/app_constants.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_colors.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';
import 'package:vehicle_speed_estimator/core/utils/haversine_calculator.dart';
import 'package:vehicle_speed_estimator/core/widgets/cmp_app_bar.dart';
import 'package:vehicle_speed_estimator/core/widgets/cmp_button.dart';
import 'package:vehicle_speed_estimator/core/widgets/distance_badge.dart';
import 'package:vehicle_speed_estimator/core/widgets/step_indicator.dart';
import 'package:vehicle_speed_estimator/features/calibration/domain/calibration_notifier.dart';

class SatellitePinScreen extends ConsumerStatefulWidget {
  const SatellitePinScreen({super.key});

  @override
  ConsumerState<SatellitePinScreen> createState() => _SatellitePinScreenState();
}

class _SatellitePinScreenState extends ConsumerState<SatellitePinScreen> {
  final MapController _mapController = MapController();
  LatLng? _pinA;
  LatLng? _pinB;
  bool _selectingPinA = true;
  double _distanceM = 0.0;

  void _recomputeDistance() {
    if (_pinA != null && _pinB != null) {
      _distanceM = HaversineCalculator.distanceMeters(
        lat1: _pinA!.latitude,
        lon1: _pinA!.longitude,
        lat2: _pinB!.latitude,
        lon2: _pinB!.longitude,
      );
    } else {
      _distanceM = 0.0;
    }
    setState(() {});
  }

  void _dropCurrentPin() {
    final center = _mapController.camera.center;
    if (_selectingPinA) {
      _pinA = center;
      _selectingPinA = false; // Auto switch to Pin B
    } else {
      _pinB = center;
    }
    _recomputeDistance();
  }

  void _onContinue() {
    if (_pinA == null ||
        _pinB == null ||
        _distanceM < AppConstants.minGateDistanceM) {
      return;
    }

    ref
        .read(calibrationNotifierProvider.notifier)
        .setSatellitePins(
          latA: _pinA!.latitude,
          lonA: _pinA!.longitude,
          latB: _pinB!.latitude,
          lonB: _pinB!.longitude,
        );

    context.push('/calibration/gates');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.cmp;
    final canContinue = _distanceM >= AppConstants.minGateDistanceM;

    return Scaffold(
      appBar: CmpAppBar(
        title: 'দূরত্ব পরিমাপ / Calibrate',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(
                AppConstants.defaultMapCenterLatitude,
                AppConstants.defaultMapCenterLongitude,
              ),
              initialZoom: AppConstants.satelliteZoomTarget,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.example.vehicle_speed_estimator',
              ),
              MarkerLayer(
                markers: [
                  if (_pinA != null)
                    Marker(
                      point: _pinA!,
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFFFFED00),
                        size: 36,
                      ),
                    ),
                  if (_pinB != null)
                    Marker(
                      point: _pinB!,
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF2FD27A),
                        size: 36,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const Center(child: Icon(Icons.add, size: 32, color: Colors.white)),
          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: CmpSpacing.space8),
                  child: StepIndicator(currentStep: 2),
                ),
                DistanceBadge(distanceM: _distanceM),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(CmpSpacing.space16),
                  color: colors.surface.withValues(alpha: 0.95),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SegmentedButton<bool>(
                              segments: const [
                                ButtonSegment(
                                  value: true,
                                  label: Text('পিন এ / Pin A'),
                                ),
                                ButtonSegment(
                                  value: false,
                                  label: Text('পিন বি / Pin B'),
                                ),
                              ],
                              selected: {_selectingPinA},
                              onSelectionChanged: (set) =>
                                  setState(() => _selectingPinA = set.first),
                            ),
                          ),
                          const SizedBox(width: CmpSpacing.space8),
                          IconButton.outlined(
                            icon: const Icon(Icons.undo),
                            onPressed: () {
                              if (_pinB != null) {
                                _pinB = null;
                              } else if (_pinA != null) {
                                _pinA = null;
                                _selectingPinA = true;
                              }
                              _recomputeDistance();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: CmpSpacing.space12),
                      Row(
                        children: [
                          Expanded(
                            child: CmpButton(
                              label: 'পিন বসান / Drop Pin',
                              icon: Icons.pin_drop,
                              variant: CmpButtonVariant.secondary,
                              onPressed: _dropCurrentPin,
                            ),
                          ),
                          const SizedBox(width: CmpSpacing.space12),
                          Expanded(
                            child: CmpButton(
                              label: 'পরবর্তী / Continue',
                              onPressed: canContinue ? _onContinue : null,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // Quick fallback dialog
                          ref
                              .read(calibrationNotifierProvider.notifier)
                              .setFallbackDistance(30.0);
                          context.push('/calibration/gates');
                        },
                        child: Text(
                          'চিহ্ন দেখতে পাচ্ছেন না? ডিফল্ট ৩০মি নির্বাচন করুন',
                          style: CmpTypography.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
