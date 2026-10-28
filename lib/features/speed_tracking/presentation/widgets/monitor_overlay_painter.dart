import 'package:flutter/material.dart';
import 'package:vehicle_speed_estimator/core/theme/overlay_colors.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/tracked_vehicle_state.dart';
import 'package:vehicle_speed_estimator/features/speed_tracking/domain/models/virtual_gate.dart';

class MonitorOverlayPainter extends CustomPainter {
  MonitorOverlayPainter({
    required this.tracksNotifier,
    required this.gateA,
    required this.gateB,
  }) : super(repaint: tracksNotifier);

  final ValueNotifier<List<TrackedVehicleState>> tracksNotifier;
  final VirtualGate? gateA;
  final VirtualGate? gateB;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw Gate A
    if (gateA != null) {
      final pA = Paint()
        ..color = OverlayColors.gateA.withValues(alpha: 0.8)
        ..strokeWidth = 2.5;
      canvas.drawLine(
        Offset(gateA!.p1.x * w, gateA!.p1.y * h),
        Offset(gateA!.p2.x * w, gateA!.p2.y * h),
        pA,
      );
    }

    // Draw Gate B
    if (gateB != null) {
      final pB = Paint()
        ..color = OverlayColors.gateB.withValues(alpha: 0.8)
        ..strokeWidth = 2.5;
      canvas.drawLine(
        Offset(gateB!.p1.x * w, gateB!.p1.y * h),
        Offset(gateB!.p2.x * w, gateB!.p2.y * h),
        pB,
      );
    }

    // Draw Gate M (Midpoint)
    if (gateA != null && gateB != null) {
      final pM = Paint()
        ..color = OverlayColors.gateM.withValues(alpha: 0.7)
        ..strokeWidth = 1.5;
      final m1 = Offset(
        (gateA!.p1.x + gateB!.p1.x) * 0.5 * w,
        (gateA!.p1.y + gateB!.p1.y) * 0.5 * h,
      );
      final m2 = Offset(
        (gateA!.p2.x + gateB!.p2.x) * 0.5 * w,
        (gateA!.p2.y + gateB!.p2.y) * 0.5 * h,
      );
      _drawDashedLine(canvas, m1, m2, pM);
    }

    // Draw tracked vehicles bounding boxes
    final paintBox = Paint()
      ..color = OverlayColors.trackedBox
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final track in tracksNotifier.value) {
      final rect = Rect.fromLTRB(
        track.left * w,
        track.top * h,
        track.right * w,
        track.bottom * h,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        paintBox,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dash = 8.0, gap = 6.0;
    final total = (p2 - p1).distance;
    if (total <= 0) return;
    final dir = (p2 - p1) / total;
    double d = 0.0;
    while (d < total) {
      final s = p1 + dir * d;
      final e = p1 + dir * (d + dash).clamp(0.0, total);
      canvas.drawLine(s, e, paint);
      d += dash + gap;
    }
  }

  @override
  bool shouldRepaint(MonitorOverlayPainter oldDelegate) =>
      oldDelegate.gateA != gateA || oldDelegate.gateB != gateB;
}

