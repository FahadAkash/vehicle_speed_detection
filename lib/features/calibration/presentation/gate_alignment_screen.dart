import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vehicle_speed_estimator/core/services/camera_service.dart';
import 'package:vehicle_speed_estimator/core/theme/cmp_spacing.dart';
import 'package:vehicle_speed_estimator/core/theme/overlay_colors.dart';
import 'package:vehicle_speed_estimator/core/utils/geometry_utils.dart';
import 'package:vehicle_speed_estimator/core/widgets/cmp_banner.dart';
import 'package:vehicle_speed_estimator/core/widgets/gate_handle.dart';
import 'package:vehicle_speed_estimator/core/widgets/live_camera_preview.dart';
import 'package:vehicle_speed_estimator/features/calibration/domain/calibration_notifier.dart';
import 'package:vehicle_speed_estimator/features/calibration/presentation/widgets/gate_alignment_controls.dart';
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
  bool _showHint = true;
  double _aX1 = 0.25, _aY1 = 0.20, _aX2 = 0.25, _aY2 = 0.78;
  double _bX1 = 0.75, _bY1 = 0.20, _bX2 = 0.75, _bY2 = 0.78;

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
    if (mounted) setState(() => _cameraController = controller);
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

  void _shiftGateA(Offset d, double w, double h) {
    setState(() {
      final dx = d.dx / w;
      final dy = d.dy / h;
      _aX1 = (_aX1 + dx).clamp(0.05, 0.95);
      _aX2 = (_aX2 + dx).clamp(0.05, 0.95);
      _aY1 = (_aY1 + dy).clamp(0.12, 0.86);
      _aY2 = (_aY2 + dy).clamp(0.12, 0.86);
    });
  }

  void _shiftGateB(Offset d, double w, double h) {
    setState(() {
      final dx = d.dx / w;
      final dy = d.dy / h;
      _bX1 = (_bX1 + dx).clamp(0.05, 0.95);
      _bX2 = (_bX2 + dx).clamp(0.05, 0.95);
      _bY1 = (_bY1 + dy).clamp(0.12, 0.86);
      _bY2 = (_bY2 + dy).clamp(0.12, 0.86);
    });
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
              // Gate A Top, Mid, Bottom Handles
              Positioned(
                left: (_aX1 * w) - 24,
                top: (_aY1 * h) - 24,
                child: GateHandle(
                  color: OverlayColors.gateA,
                  onPanUpdate: (d) => setState(() {
                    _aX1 = (_aX1 + d.dx / w).clamp(0.05, 0.95);
                    _aY1 = (_aY1 + d.dy / h).clamp(0.12, 0.86);
                  }),
                ),
              ),
              Positioned(
                left: (((_aX1 + _aX2) / 2) * w) - 24,
                top: (((_aY1 + _aY2) / 2) * h) - 24,
                child: GateHandle(
                  color: OverlayColors.gateA.withValues(alpha: 0.6),
                  onPanUpdate: (d) => _shiftGateA(d, w, h),
                ),
              ),
              Positioned(
                left: (_aX2 * w) - 24,
                top: (_aY2 * h) - 24,
                child: GateHandle(
                  color: OverlayColors.gateA,
                  onPanUpdate: (d) => setState(() {
                    _aX2 = (_aX2 + d.dx / w).clamp(0.05, 0.95);
                    _aY2 = (_aY2 + d.dy / h).clamp(0.12, 0.86);
                  }),
                ),
              ),
              // Gate B Top, Mid, Bottom Handles
              Positioned(
                left: (_bX1 * w) - 24,
                top: (_bY1 * h) - 24,
                child: GateHandle(
                  color: OverlayColors.gateB,
                  onPanUpdate: (d) => setState(() {
                    _bX1 = (_bX1 + d.dx / w).clamp(0.05, 0.95);
                    _bY1 = (_bY1 + d.dy / h).clamp(0.12, 0.86);
                  }),
                ),
              ),
              Positioned(
                left: (((_bX1 + _bX2) / 2) * w) - 24,
                top: (((_bY1 + _bY2) / 2) * h) - 24,
                child: GateHandle(
                  color: OverlayColors.gateB.withValues(alpha: 0.6),
                  onPanUpdate: (d) => _shiftGateB(d, w, h),
                ),
              ),
              Positioned(
                left: (_bX2 * w) - 24,
                top: (_bY2 * h) - 24,
                child: GateHandle(
                  color: OverlayColors.gateB,
                  onPanUpdate: (d) => setState(() {
                    _bX2 = (_bX2 + d.dx / w).clamp(0.05, 0.95);
                    _bY2 = (_bY2 + d.dy / h).clamp(0.12, 0.86);
                  }),
                ),
              ),
              // Top Bar per AGENT.md Section 9.4 wireframe
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: GateAlignmentTopBar(
                  onBack: () => context.pop(),
                  isSteady: isSteady,
                  distanceM: distanceM,
                ),
              ),
              if (_showHint)
                Positioned(
                  top: 56,
                  left: 80,
                  right: 80,
                  child: GestureDetector(
                    onTap: () => setState(() => _showHint = false),
                    child: const CmpBanner(
                      message:
                          'মানচিত্রে চিহ্নিত দুটি চিহ্নের সাথে গেট A ও B মিলিয়ে নিন / Align A and B with landmarks',
                      variant: CmpBannerVariant.info,
                    ),
                  ),
                ),
              // Bottom Controls per Section 9.4 wireframe
              Positioned(
                bottom: CmpSpacing.space16,
                left: 0,
                right: 0,
                child: GateAlignmentBottomBar(
                  onReset: () => setState(() {
                    _aX1 = 0.25;
                    _aY1 = 0.20;
                    _aX2 = 0.25;
                    _aY2 = 0.78;
                    _bX1 = 0.75;
                    _bY1 = 0.20;
                    _bX2 = 0.75;
                    _bY2 = 0.78;
                  }),
                  onConfirm: _onConfirm,
                  isConfirmEnabled: isSteady,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

