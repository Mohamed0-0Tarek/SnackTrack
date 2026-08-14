import 'package:flutter/material.dart';
import 'custom_card.dart';

class MetabolicHealthCard extends StatelessWidget {
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  const MetabolicHealthCard({
    super.key,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFat = 0,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final total = totalProtein + totalCarbs + totalFat;
    final proteinRatio = total > 0 ? totalProtein / total : 0.33;
    final carbRatio = total > 0 ? totalCarbs / total : 0.33;
    final fatRatio = total > 0 ? totalFat / total : 0.34;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_heart_outlined, color: scheme.primary, size: 20),
              const SizedBox(width: 6),
              Text('Metabolic Health', style: tt.headlineMedium),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Weekly macronutrient distribution: ${total.toStringAsFixed(0)}g total',
            style: tt.bodySmall,
          ),
          const SizedBox(height: 14),
          _MacroBar(label: 'PROTEIN', value: proteinRatio, color: scheme.primary),
          const SizedBox(height: 8),
          _MacroBar(label: 'CARBS', value: carbRatio, color: scheme.tertiary),
          const SizedBox(height: 8),
          _MacroBar(label: 'FATS', value: fatRatio, color: scheme.secondary),
        ],
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _MacroBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: tt.labelSmall?.copyWith(letterSpacing: 0.8)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: color.withAlpha(30),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text('${(value * 100).toStringAsFixed(0)}%', style: tt.bodySmall, textAlign: TextAlign.end),
        ),
      ],
    );
  }
}
