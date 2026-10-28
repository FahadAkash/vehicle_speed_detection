import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vehicle_speed_estimator/core/services/camera_service.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_typography.dart';
import 'package:vehicle_speed_estimator/core/theme/overlay_colors.dart';
import 'package:vehicle_speed_estimator/core/utils/geometry_utils.dart';
import 'package:vehicle_speed_estimator/core/widgets/cmp_button.dart';
import 'package:vehicle_speed_estimator/core/widgets/gate_handle.dart';
import 'package:vehicle_speed_estimator/core/widgets/live_camera_preview.dart';
import 'package:vehicle_speed_estimator/core/widgets/stability_pill.dart';
import 'package:vehicle_speed_estimator/features/calibration/domain/calibration_notifier.dart';
import 'package:vehicle_speed_estimator/features/calibration/presentation/widgets/gate_lines_painter.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/virtual_gate.dart';

class GateAlignmentScreen extends ConsumerStatefulWidget {
  const GateAlignmentScreen({super.key});

  @override
  ConsumerState<GateAlignmentScreen> createState() =>
      _GateAlignmentScreenState();
}

class _GateAlignmentScreenState extends ConsumerState<GateAlignmentScreen> {
  CameraController? _cameraController;
  double _aX1 = 0.25, _aY1 = 0.1, _aX2 = 0.25, _aY2 = 0.9;
  double _bX1 = 0.75, _bY1 = 0.1, _bX2 = 0.75, _bY2 = 0.9;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return;
    final controller = await ref.read(cameraServiceProvider).initialize();
    if (mounted) {
      setState(() => _cameraController = controller);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _onConfirm() {
    final gateA = VirtualGate(
      name: 'Gate A',
      p1: Vec2(_aX1, _aY1),
      p2: Vec2(_aX2, _aY2),
    );
    final gateB = VirtualGate(
      name: 'Gate B',
      p1: Vec2(_bX1, _bY1),
      p2: Vec2(_bX2, _bY2),
    );

    ref.read(calibrationNotifierProvider.notifier).setGates(gateA, gateB);
    context.push('/monitor');
  }

  @override
  Widget build(BuildContext context) {
    final isSteady = ref.watch(
      calibrationNotifierProvider.select((s) => s.isSteady),
    );
    final distanceM = ref.watch(
      calibrationNotifierProvider.select((s) => s.config.distanceM),
    );

    final mX1 = (_aX1 + _bX1) / 2.0;
    final mY1 = (_aY1 + _bY1) / 2.0;
    final mX2 = (_aX2 + _bX2) / 2.0;
    final mY2 = (_aY2 + _bY2) / 2.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          return Stack(
            children: [
              LiveCameraPreview(controller: _cameraController),
              CustomPaint(
                size: Size(w, h),
                painter: GateLinesPainter(
                  a1: Offset(_aX1 * w, _aY1 * h),
                  a2: Offset(_aX2 * w, _aY2 * h),
                  b1: Offset(_bX1 * w, _bY1 * h),
                  b2: Offset(_bX2 * w, _bY2 * h),
                  m1: Offset(mX1 * w, mY1 * h),
                  m2: Offset(mX2 * w, mY2 * h),
                ),
              ),
              Positioned(
                left: (_aX1 * w) - 24,
                top: (_aY1 * h) - 24,
                child: GateHandle(
                  color: OverlayColors.gateA,
                  onPanUpdate: (d) => setState(() {
                    _aX1 = (_aX1 + d.dx / w).clamp(0.05, 0.95);
                    _aY1 = (_aY1 + d.dy / h).clamp(0.05, 0.95);
                  }),
                ),
              ),
              Positioned(
                left: (_aX2 * w) - 24,
                top: (_aY2 * h) - 24,
                child: GateHandle(
                  color: OverlayColors.gateA,
                  onPanUpdate: (d) => setState(() {
                    _aX2 = (_aX2 + d.dx / w).clamp(0.05, 0.95);
                    _aY2 = (_aY2 + d.dy / h).clamp(0.05, 0.95);
                  }),
                ),
              ),
              Positioned(
                left: (_bX1 * w) - 24,
                top: (_bY1 * h) - 24,
                child: GateHandle(
                  color: OverlayColors.gateB,
                  onPanUpdate: (d) => setState(() {
                    _bX1 = (_bX1 + d.dx / w).clamp(0.05, 0.95);
                    _bY1 = (_bY1 + d.dy / h).clamp(0.05, 0.95);
                  }),
                ),
              ),
              Positioned(
                left: (_bX2 * w) - 24,
                top: (_bY2 * h) - 24,
                child: GateHandle(
                  color: OverlayColors.gateB,
                  onPanUpdate: (d) => setState(() {
                    _bX2 = (_bX2 + d.dx / w).clamp(0.05, 0.95);
                    _bY2 = (_bY2 + d.dy / h).clamp(0.05, 0.95);
                  }),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CmpSpacing.space16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton.filled(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: CmpSpacing.space12),
                      Text(
                        'গেট সারিবদ্ধকরণ / Align Gates',
                        style: CmpTypography.title.copyWith(color: Colors.white),
                      ),
                      const Spacer(),
                      StabilityPill(isSteady: isSteady),
                      const SizedBox(width: CmpSpacing.space12),
                      Text(
                        'D = ${distanceM.toStringAsFixed(1)} m',
                        style: CmpTypography.label.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: CmpSpacing.space16,
                left: CmpSpacing.space16,
                right: CmpSpacing.space16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CmpButton(
                      label: 'রিসেট / Reset',
                      variant: CmpButtonVariant.secondary,
                      isFullWidth: false,
                      onPressed: () => setState(() {
                        _aX1 = 0.25;
                        _aY1 = 0.1;
                        _aX2 = 0.25;
                        _aY2 = 0.9;
                        _bX1 = 0.75;
                        _bY1 = 0.1;
                        _bX2 = 0.75;
                        _bY2 = 0.9;
                      }),
                    ),
                    CmpButton(
                      label: 'গেট নিশ্চিত করুন / Confirm Gates',
                      isFullWidth: false,
                      onPressed: isSteady ? _onConfirm : null,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
