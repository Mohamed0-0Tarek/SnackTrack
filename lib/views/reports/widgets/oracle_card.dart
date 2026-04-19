import 'package:flutter/material.dart';

class OracleCard extends StatelessWidget {
  const OracleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.primary.withAlpha(70)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: scheme.primary.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: scheme.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text('Digital Oracle Analysis', style: tt.headlineMedium),
            ],
          ),
          const SizedBox(height: 14),
          RichText(
            text: TextSpan(
              style: tt.bodyMedium,
              children: [
                const TextSpan(text: 'Your '),
                TextSpan(
                  text: 'thermic effect of food (TEF)',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(
                  text:
                      ' was optimized this week by increasing protein intake during your first meal. This shift correlates with a 15% reduction in afternoon lethargy reports.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'The weight fluctuation observed on Wednesday (Day 3) is categorized as transient water retention, likely due to the sodium-rich meal logged on Tuesday night. By Thursday, your baseline trend returned to the projected trajectory.',
            style: tt.bodyMedium,
          ),
          const SizedBox(height: 14),
          Text(
            'RECOMMENDATION:',
            style: tt.labelSmall?.copyWith(
              color: scheme.primary,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '"Maintain current macros for another 4 days to solidify this metabolic floor before adjusting deficit variables."',
            style: tt.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
