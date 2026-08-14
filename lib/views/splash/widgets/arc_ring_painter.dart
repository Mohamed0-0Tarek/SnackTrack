import 'dart:math' as math;

import 'package:flutter/material.dart';

class ArcRingPainter extends CustomPainter {
  final Color primary;
  final Color secondary;
  const ArcRingPainter({required this.primary, required this.secondary});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect   = Rect.fromCircle(center: center, radius: radius);

    // Dim full ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = primary.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Gradient arc using project colors
    canvas.drawArc(
      rect, 0, math.pi * 1.4, false,
      Paint()
        ..shader = SweepGradient(
          colors: [primary, secondary, Colors.transparent],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant ArcRingPainter old) =>
      old.primary != primary || old.secondary != secondary;
}