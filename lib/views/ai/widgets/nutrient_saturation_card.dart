import 'package:flutter/material.dart';
import '../../../services/weekly_report_service.dart';
import 'custom_card.dart';

class NutrientSaturationCard extends StatelessWidget {
  final WeeklyReport? report;

  const NutrientSaturationCard({super.key, this.report});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final protein = report?.totalProtein ?? 0;
    final carbs = report?.totalCarbs ?? 0;
    final fat = report?.totalFat ?? 0;
    final total = protein + carbs + fat;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_outline_rounded, color: scheme.primary, size: 20),
              const SizedBox(width: 6),
              Text('Nutrient Saturation', style: tt.headlineMedium),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Total macros: ${total.toStringAsFixed(0)}g',
            style: tt.bodySmall,
          ),
          const SizedBox(height: 14),
          _StatRow(label: 'Protein', value: '${protein.toStringAsFixed(0)}g', color: scheme.primary),
          const SizedBox(height: 8),
          _StatRow(label: 'Carbs', value: '${carbs.toStringAsFixed(0)}g', color: scheme.tertiary),
          const SizedBox(height: 8),
          _StatRow(label: 'Fat', value: '${fat.toStringAsFixed(0)}g', color: scheme.secondary),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: tt.bodyMedium),
          ],
        ),
        Text(value, style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
