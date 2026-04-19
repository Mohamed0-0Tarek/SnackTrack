import 'dart:math';
import 'package:flutter/material.dart';
import 'shared_card.dart';

class MacroIntegrityCard extends StatelessWidget {
  const MacroIntegrityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Macro Integrity', style: tt.headlineMedium),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: _DonutPainter(
                  primaryColor: scheme.primary,
                  secondaryColor: scheme.secondary,
                  tertiaryColor: scheme.tertiary,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '92%',
                        style: tt.displayMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text('ADHERENCE', style: tt.labelSmall),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _MacroRow(label: 'PROTEIN', value: '185g', color: scheme.primary),
          const SizedBox(height: 10),
          _MacroRow(label: 'CARBS', value: '210g', color: scheme.secondary),
          const SizedBox(height: 10),
          _MacroRow(label: 'FATS', value: '65g', color: scheme.tertiary),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MacroRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: tt.bodyMedium),
        Text(
          value,
          style: tt.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;

  const _DonutPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 14.0;
    const gapAngle = 0.08;

    final segments = [
      (0.40, primaryColor),
      (0.33, secondaryColor),
      (0.19, tertiaryColor),
    ];

    double startAngle = -pi / 2;
    for (final seg in segments) {
      final sweepAngle = seg.$1 * 2 * pi - gapAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = seg.$2
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
      startAngle += sweepAngle + gapAngle;
    }

    // Remaining track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      (1 - 0.92) * 2 * pi,
      false,
      Paint()
        ..color = primaryColor.withAlpha(40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.primaryColor != primaryColor ||
      old.secondaryColor != secondaryColor ||
      old.tertiaryColor != tertiaryColor;
}
