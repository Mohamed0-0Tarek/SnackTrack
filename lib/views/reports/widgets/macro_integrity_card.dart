import 'dart:math';
import 'package:flutter/material.dart';
import 'shared_card.dart';

/// Macro donut chart — now driven by real [macroPercentages] from
/// WeeklyReportController instead of hardcoded 40/33/19 splits.
class MacroIntegrityCard extends StatelessWidget {
  /// [proteinPct, carbsPct, fatPct] each in 0.0–1.0 range.
  final List<double> macroPercentages;
  final String totalProtein;
  final String totalCarbs;
  final String totalFat;

  const MacroIntegrityCard({
    super.key,
    required this.macroPercentages,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final proteinPct = macroPercentages.isNotEmpty ? macroPercentages[0] : 0.33;
    final carbsPct = macroPercentages.length > 1 ? macroPercentages[1] : 0.33;
    final fatPct = macroPercentages.length > 2 ? macroPercentages[2] : 0.34;

    final adherencePct =
        ((proteinPct + carbsPct + fatPct) * 100).clamp(0, 100).round();

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
                  proteinPct: proteinPct,
                  carbsPct: carbsPct,
                  fatPct: fatPct,
                  primaryColor: scheme.primary,
                  secondaryColor: scheme.secondary,
                  tertiaryColor: scheme.tertiary,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$adherencePct%',
                        style: tt.displayMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text('LOGGED', style: tt.labelSmall),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _MacroRow(
              label: 'PROTEIN',
              value: totalProtein,
              color: scheme.primary),
          const SizedBox(height: 10),
          _MacroRow(
              label: 'CARBS',
              value: totalCarbs,
              color: scheme.secondary),
          const SizedBox(height: 10),
          _MacroRow(
              label: 'FATS', value: totalFat, color: scheme.tertiary),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MacroRow(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: tt.bodyMedium),
        Text(value,
            style: tt.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 15)),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double proteinPct;
  final double carbsPct;
  final double fatPct;
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;

  const _DonutPainter({
    required this.proteinPct,
    required this.carbsPct,
    required this.fatPct,
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
      (proteinPct, primaryColor),
      (carbsPct, secondaryColor),
      (fatPct, tertiaryColor),
    ];

    double startAngle = -pi / 2;
    for (final seg in segments) {
      if (seg.$1 <= 0) continue;
      final sweepAngle = seg.$1 * 2 * pi - gapAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle.clamp(0.01, 2 * pi),
        false,
        Paint()
          ..color = seg.$2
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
      startAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.proteinPct != proteinPct ||
      old.carbsPct != carbsPct ||
      old.fatPct != fatPct;
}
