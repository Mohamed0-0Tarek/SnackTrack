import 'package:flutter/material.dart';
import 'custom_card.dart';

class OracleVerdictCard extends StatelessWidget {
  final String? summary;
  final List<String> recommendations;
  final bool isLoading;

  const OracleVerdictCard({
    super.key,
    this.summary,
    this.recommendations = const [],
    this.isLoading = false,
  });

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
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else ...[
            Text(
              summary != null ? '"$summary"' : 'Your metabolic data is being analyzed.',
              style: tt.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: scheme.onSurface.withAlpha(180),
                height: 1.6,
              ),
            ),
            if (recommendations.isNotEmpty) ...[
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
              ...recommendations.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.arrow_forward_rounded, color: scheme.primary, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(r, style: tt.bodyMedium?.copyWith(height: 1.4))),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
