import 'package:flutter/material.dart';
import 'package:vehicle_speed_estimator/core/theme/overlay_colors.dart';

/// Canvas painter for Gate A, Gate B, and auto Midpoint Gate M.
/// Accurately renders wireframe per AGENT.md Section 9.4.
class GateLinesPainter extends CustomPainter {
  const GateLinesPainter({
    required this.a1,
    required this.a2,
    required this.b1,
    required this.b2,
    required this.m1,
    required this.m2,
  });

  final Offset a1, a2, b1, b2, m1, m2;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Drop shadows for high contrast under bright outdoor lighting
    final shadowPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(a1, a2, shadowPaint);
    canvas.drawLine(b1, b2, shadowPaint);

    // 2. Colored Gate lines
    final paintA = Paint()
      ..color = OverlayColors.gateA
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    final paintB = Paint()
      ..color = OverlayColors.gateB
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    final paintM = Paint()
      ..color = OverlayColors.gateM
      ..strokeWidth = 2.5;

    canvas.drawLine(a1, a2, paintA);
    canvas.drawLine(b1, b2, paintB);

    // 3. Dashed line for Gate M
    const dashLength = 8.0, gapLength = 6.0;
    final totalLen = (m2 - m1).distance;
    if (totalLen > 0) {
      final dir = (m2 - m1) / totalLen;
      double dist = 0.0;
      while (dist < totalLen) {
        final start = m1 + dir * dist;
        final end = m1 + dir * (dist + dashLength).clamp(0.0, totalLen);
        canvas.drawLine(start, end, shadowPaint..strokeWidth = 4.5);
        canvas.drawLine(start, end, paintM);
        dist += dashLength + gapLength;
      }
    }

    // 4. Badges / Labels matching AGENT.md Section 9.4 wireframe
    _drawBadge(canvas, a1, 'A', OverlayColors.gateA);
    _drawBadge(canvas, b1, 'B', OverlayColors.gateB);
    _drawBadge(canvas, m1, 'M', OverlayColors.gateM);
    _drawPill(canvas, m2, 'M · auto', OverlayColors.gateM);
  }

  void _drawBadge(Canvas canvas, Offset pos, String letter, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: letter,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeCenter = Offset(pos.dx, pos.dy - 24);
    const radius = 14.0;

    // Drop shadow
    canvas.drawCircle(
      badgeCenter.translate(0, 2),
      radius,
      Paint()
        ..color = Colors.black87
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    // Fill & outline
    canvas.drawCircle(badgeCenter, radius, Paint()..color = color);
    canvas.drawCircle(
      badgeCenter,
      radius,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    tp.paint(
      canvas,
      Offset(badgeCenter.dx - (tp.width / 2), badgeCenter.dy - (tp.height / 2)),
    );
  }

  void _drawPill(Canvas canvas, Offset pos, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeWidth = tp.width + 16;
    const badgeHeight = 22.0;
    final badgeLeft = pos.dx - (badgeWidth / 2);
    final badgeTop = pos.dy + 8;

    final badgeRect = Rect.fromLTWH(
      badgeLeft,
      badgeTop,
      badgeWidth,
      badgeHeight,
    );
    final rrect = RRect.fromRectAndRadius(badgeRect, const Radius.circular(11));

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black54
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
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
      Offset(badgeLeft + 8, badgeTop + (badgeHeight - tp.height) / 2),
    );
  }

  @override
  bool shouldRepaint(GateLinesPainter oldDelegate) =>
      oldDelegate.a1 != a1 ||
      oldDelegate.a2 != a2 ||
      oldDelegate.b1 != b1 ||
      oldDelegate.b2 != b2 ||
      oldDelegate.m1 != m1 ||
      oldDelegate.m2 != m2;
}

