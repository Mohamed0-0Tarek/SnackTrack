import 'package:flutter/material.dart';
import 'highlighted_text.dart';

class InsightCard extends StatelessWidget {
  const InsightCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: scheme.primary, width: 3)),
        boxShadow: isDark
            ? null
            : [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(
              'SNAKE AI INSIGHT',
              style: tt.labelSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: HighlightedText(
              raw:
                  'Correct assessment. Your biometric feedback indicates a {glucose dip}. Recommended adjustment:',
              baseStyle: tt.bodyLarge!,
              highlightStyle: tt.bodyLarge!.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? scheme.primary.withAlpha(20)
                    : scheme.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: scheme.primary.withAlpha(50),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.grain, color: scheme.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OPTIMAL INTAKE',
                        style: tt.labelSmall?.copyWith(letterSpacing: 1.2),
                      ),
                      Text(
                        '35g Complex Carbs',
                        style: tt.headlineMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'METABOLIC RECOVERY',
                      style: tt.labelSmall?.copyWith(letterSpacing: 1),
                    ),
                    Text(
                      '88%',
                      style: tt.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.88,
                    minHeight: 6,
                    backgroundColor: scheme.primary.withAlpha(30),
                    valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Next window for peak performance: 16:30 (T-minus 2h)',
                  style: tt.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
