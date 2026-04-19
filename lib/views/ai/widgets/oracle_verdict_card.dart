import 'package:flutter/material.dart';
import 'custom_card.dart';

class OracleVerdictCard extends StatelessWidget {
  const OracleVerdictCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return CustomCard(
      accentBorder: scheme.secondary.withAlpha(80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: scheme.secondary, size: 18),
              const SizedBox(width: 8),
              Text("The Oracle's Verdict", style: tt.headlineMedium),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"Your cortisol rhythms suggest a minor misalignment between 3 PM and 5 PM. We recommend shifting your complex carbohydrate intake 45 minutes earlier to buffer the afternoon dip."',
            style: tt.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: scheme.onSurface.withAlpha(180),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'STRATEGIC ADJUSTMENT',
            style: tt.labelSmall?.copyWith(
              color: scheme.secondary,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          AdjustmentRow(
            text:
                'Increase fiber intake by 8g during breakfast to extend satiety.',
            color: scheme.primary,
          ),
          const SizedBox(height: 8),
          AdjustmentRow(
            text: 'Add 300mg Potassium to post-workout hydration.',
            color: scheme.primary,
          ),
        ],
      ),
    );
  }
}

class AdjustmentRow extends StatelessWidget {
  final String text;
  final Color color;
  const AdjustmentRow({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.arrow_forward_rounded, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: tt.bodyMedium?.copyWith(height: 1.4)),
        ),
      ],
    );
  }
}
