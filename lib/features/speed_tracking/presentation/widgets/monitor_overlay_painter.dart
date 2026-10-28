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

    final shadowPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    // Draw Gate A
    if (gateA != null) {
      final p1 = Offset(gateA!.p1.x * w, gateA!.p1.y * h);
      final p2 = Offset(gateA!.p2.x * w, gateA!.p2.y * h);
      final pA = Paint()
        ..color = OverlayColors.gateA
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(p1, p2, shadowPaint);
      canvas.drawLine(p1, p2, pA);
      _drawBadge(canvas, p1, 'A', OverlayColors.gateA);
    }

    // Draw Gate B
    if (gateB != null) {
      final p1 = Offset(gateB!.p1.x * w, gateB!.p1.y * h);
      final p2 = Offset(gateB!.p2.x * w, gateB!.p2.y * h);
      final pB = Paint()
        ..color = OverlayColors.gateB
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(p1, p2, shadowPaint);
      canvas.drawLine(p1, p2, pB);
      _drawBadge(canvas, p1, 'B', OverlayColors.gateB);
    }

    // Draw Gate M (Midpoint)
    if (gateA != null && gateB != null) {
      final m1 = Offset(
        (gateA!.p1.x + gateB!.p1.x) * 0.5 * w,
        (gateA!.p1.y + gateB!.p1.y) * 0.5 * h,
      );
      final m2 = Offset(
        (gateA!.p2.x + gateB!.p2.x) * 0.5 * w,
        (gateA!.p2.y + gateB!.p2.y) * 0.5 * h,
      );
      final pM = Paint()
        ..color = OverlayColors.gateM
        ..strokeWidth = 2.0;

      _drawDashedLine(canvas, m1, m2, shadowPaint..strokeWidth = 4.0);
      _drawDashedLine(canvas, m1, m2, pM);
      _drawBadge(canvas, m1, 'M', OverlayColors.gateM);
    }

    // Draw tracked vehicles bounding boxes, class labels, and verified speeds
    final paintBox = Paint()
      ..color = OverlayColors.trackedBox
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (final track in tracksNotifier.value) {
      final rect = Rect.fromLTRB(
        track.left * w,
        track.top * h,
        track.right * w,
        track.bottom * h,
      );
      // Double stroke: black shadow outline for contrast against any background
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        paintBox,
      );

      // Vehicle class and ID tag at top-left of bounding box
      final label =
          '${track.vehicleClass.wireName.toUpperCase()} #${track.trackId}';
      _drawTag(canvas, Offset(rect.left, rect.top - 20), label);

      // If verified, draw floating SpeedChip next to vehicle
      if (track.isVerified && track.verifiedSpeedKmh != null) {
        final speedText = '${track.verifiedSpeedKmh!.toStringAsFixed(1)} km/h';
        _drawSpeedChip(
          canvas,
          Offset(rect.right + 6, rect.top + (rect.height / 2) - 14),
          speedText,
        );
      }
    }
  }

  void _drawBadge(Canvas canvas, Offset pos, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeRect = Rect.fromCenter(
      center: Offset(pos.dx, pos.dy - 16),
      width: 26,
      height: 22,
    );
    final rrect = RRect.fromRectAndRadius(badgeRect, const Radius.circular(6));

    canvas.drawRRect(rrect, Paint()..color = color);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    tp.paint(
      canvas,
      Offset(badgeRect.left + (badgeRect.width - tp.width) / 2, badgeRect.top + 3),
    );
  }

  void _drawTag(Canvas canvas, Offset pos, String text) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final tagRect = Rect.fromLTWH(pos.dx, pos.dy, tp.width + 10, 18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(tagRect, const Radius.circular(4)),
      Paint()..color = Colors.black87,
    );
    tp.paint(canvas, Offset(pos.dx + 5, pos.dy + 3));
  }

  void _drawSpeedChip(Canvas canvas, Offset pos, String speed) {
    final tp = TextPainter(
      text: TextSpan(
        text: speed,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final chipRect = Rect.fromLTWH(pos.dx, pos.dy, tp.width + 14, 24);
    final rrect = RRect.fromRectAndRadius(chipRect, const Radius.circular(12));

    canvas.drawRRect(rrect, Paint()..color = OverlayColors.verifiedBox);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    tp.paint(canvas, Offset(pos.dx + 7, pos.dy + 5));
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
