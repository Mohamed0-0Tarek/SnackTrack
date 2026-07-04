import 'package:flutter/material.dart';

/// AI Oracle verdict card — now driven by real data from
/// WeeklyReportController's AI oracle call instead of hardcoded text.
class OracleCard extends StatelessWidget {
  final String? grade;
  final String? summary;
  final List<String> recommendations;
  final bool isLoading;

  const OracleCard({
    super.key,
    required this.grade,
    required this.summary,
    required this.recommendations,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            scheme.primary.withAlpha(isDark ? 60 : 30),
            scheme.secondary.withAlpha(isDark ? 60 : 30),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: scheme.primary.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: scheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'ORACLE VERDICT',
                style: tt.labelSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (isLoading) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(),
              ),
            ),
          ] else ...[
            // Grade
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  grade ?? '—',
                  style: tt.displayLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: scheme.primary,
                    fontSize: 56,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      summary ?? 'Not enough data this week.',
                      style: tt.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),

            if (recommendations.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...recommendations.map(
                (rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.chevron_right,
                          color: scheme.primary, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(rec, style: tt.bodySmall),
                      ),
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
