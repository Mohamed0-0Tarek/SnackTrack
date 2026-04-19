import 'dart:math';
import 'package:flutter/material.dart';

class GradeCard extends StatelessWidget {
  const GradeCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: SizedBox(
        width: 130,
        height: 130,
        child: CustomPaint(
          painter: _RingPainter(
            color: scheme.primary,
            trackColor: scheme.primary.withAlpha(30),
            progress: 0.92,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'A',
                  style: tt.displayLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 44,
                    height: 1,
                  ),
                ),
                Text(
                  'OPTIMAL',
                  style: tt.labelSmall?.copyWith(letterSpacing: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final Color trackColor;
  final double progress;

  const _RingPainter({
    required this.color,
    required this.trackColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 10.0;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      progress * 2 * pi,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.color != color || old.progress != progress;
}
