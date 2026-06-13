import 'dart:math';
import 'package:flutter/material.dart';
import 'shared_card.dart';

class CaloricFluxCard extends StatelessWidget {
  const CaloricFluxCard({super.key});

  static const List<double> intakeData = [
    2200,
    2450,
    2100,
    2600,
    2350,
    2500,
    2450,
  ];
  static const List<double> weightData = [
    175.0,
    174.8,
    175.2,
    174.6,
    174.4,
    174.3,
    174.2,
  ];
  static const List<String> days = [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Caloric Flux vs. Weight', style: tt.headlineMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Correlation of intake against daily weigh-ins',
                      style: tt.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegendDot(color: scheme.primary, label: 'INTAKE'),
                  const SizedBox(height: 4),
                  _LegendDot(color: scheme.secondary, label: 'WEIGHT'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: _DualLinePainter(
                intakeData: intakeData,
                weightData: weightData,
                primaryColor: scheme.primary,
                secondaryColor: scheme.secondary,
                surfaceColor: Theme.of(context).cardColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((d) => Text(d, style: tt.labelSmall)).toList(),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: tt.labelSmall),
      ],
    );
  }
}

class _DualLinePainter extends CustomPainter {
  final List<double> intakeData;
  final List<double> weightData;
  final Color primaryColor;
  final Color secondaryColor;
  final Color surfaceColor;

  const _DualLinePainter({
    required this.intakeData,
    required this.weightData,
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawLine(canvas, size, intakeData, primaryColor, dashed: false);
    _drawLine(canvas, size, weightData, secondaryColor, dashed: true);
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    List<double> data,
    Color color, {
    bool dashed = false,
  }) {
    final minVal = data.reduce(min);
    final maxVal = data.reduce(max);
    final range = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    Offset getOffset(int i) {
      final x = i * size.width / (data.length - 1);
      final y =
          size.height -
          ((data[i] - minVal) / range) * (size.height * 0.8) -
          size.height * 0.1;
      return Offset(x, y);
    }

    // Gradient fill (solid lines only)
    if (!dashed) {
      final fillPath = Path()..moveTo(0, size.height);
      for (int i = 0; i < data.length; i++) {
        final o = getOffset(i);
        if (i == 0) {
          fillPath.lineTo(o.dx, o.dy);
        } else {
          final prev = getOffset(i - 1);
          final cp1 = Offset((prev.dx + o.dx) / 2, prev.dy);
          final cp2 = Offset((prev.dx + o.dx) / 2, o.dy);
          fillPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, o.dx, o.dy);
        }
      }
      fillPath
        ..lineTo(size.width, size.height)
        ..close();

      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withAlpha(70), color.withAlpha(0)],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
      );
    }

    // Build smooth path
    final linePath = Path();
    for (int i = 0; i < data.length; i++) {
      final o = getOffset(i);
      if (i == 0) {
        linePath.moveTo(o.dx, o.dy);
      } else {
        final prev = getOffset(i - 1);
        final cp1 = Offset((prev.dx + o.dx) / 2, prev.dy);
        final cp2 = Offset((prev.dx + o.dx) / 2, o.dy);
        linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, o.dx, o.dy);
      }
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (dashed) {
      _drawDashedPath(canvas, linePath, linePaint);
    } else {
      canvas.drawPath(linePath, linePaint);
    }

    // Dots
    for (int i = 0; i < data.length; i++) {
      canvas.drawCircle(getOffset(i), 3.5, Paint()..color = color);
      canvas.drawCircle(
        getOffset(i),
        3.5,
        Paint()
          ..color = surfaceColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DualLinePainter old) =>
      old.primaryColor != primaryColor || old.secondaryColor != secondaryColor;
}
