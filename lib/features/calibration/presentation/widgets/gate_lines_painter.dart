import 'package:flutter/material.dart';
import 'package:vehicle_speed_estimator/core/theme/overlay_colors.dart';

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
    final paintA = Paint()
      ..color = OverlayColors.gateA
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    final paintB = Paint()
      ..color = OverlayColors.gateB
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    final paintM = Paint()
      ..color = OverlayColors.gateM
      ..strokeWidth = 2.0;

    canvas.drawLine(a1, a2, paintA);
    canvas.drawLine(b1, b2, paintB);

    // Dashed line for Gate M
    const dashLength = 8.0, gapLength = 6.0;
    final totalLen = (m2 - m1).distance;
    if (totalLen > 0) {
      final dir = (m2 - m1) / totalLen;
      double dist = 0.0;
      while (dist < totalLen) {
        final start = m1 + dir * dist;
        final end = m1 + dir * (dist + dashLength).clamp(0.0, totalLen);
        canvas.drawLine(start, end, paintM);
        dist += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(GateLinesPainter old) =>
      old.a1 != a1 || old.a2 != a2 || old.b1 != b1 || old.b2 != b2;
}

