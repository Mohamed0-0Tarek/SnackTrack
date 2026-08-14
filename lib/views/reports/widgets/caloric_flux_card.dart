import 'dart:math';
import 'package:flutter/material.dart';
import 'shared_card.dart';

/// Caloric trend chart — now driven by real [dailyCalories] data from
/// WeeklyReportController instead of a hardcoded static list.
class CaloricFluxCard extends StatelessWidget {
  final List<int> dailyCalories;
  final List<String> days;
  final int goalCalories;

  const CaloricFluxCard({
    super.key,
    required this.dailyCalories,
    required this.days,
    required this.goalCalories,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final data = dailyCalories.map((c) => c.toDouble()).toList();

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
                    Text('Caloric Flux', style: tt.headlineMedium),
                    const SizedBox(height: 2),
                    Text(
                      '7-day intake vs. goal ($goalCalories kcal)',
                      style: tt.bodySmall,
                    ),
                  ],
                ),
              ),
              _LegendDot(color: scheme.primary, label: 'INTAKE'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: _BarPainter(
                data: data,
                goalCalories: goalCalories.toDouble(),
                barColor: scheme.primary,
                goalColor: scheme.secondary,
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
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: tt.labelSmall),
      ],
    );
  }
}

class _BarPainter extends CustomPainter {
  final List<double> data;
  final double goalCalories;
  final Color barColor;
  final Color goalColor;

  const _BarPainter({
    required this.data,
    required this.goalCalories,
    required this.barColor,
    required this.goalColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = max(data.reduce(max), goalCalories) * 1.15;
    final barWidth = size.width / (data.length * 2);

    for (int i = 0; i < data.length; i++) {
      final x = i * (size.width / data.length) + barWidth / 2;
      final barHeight = (data[i] / maxVal) * size.height * 0.85;
      final rect = Rect.fromLTWH(
        x, size.height - barHeight, barWidth, barHeight,
      );
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
      canvas.drawRRect(
        rRect,
        Paint()..color = data[i] > 0 ? barColor : barColor.withAlpha(40),
      );
    }

    // Goal line
    final goalY = size.height - (goalCalories / maxVal) * size.height * 0.85;
    canvas.drawLine(
      Offset(0, goalY),
      Offset(size.width, goalY),
      Paint()
        ..color = goalColor
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _BarPainter old) =>
      old.data != data || old.goalCalories != goalCalories;
}
