import 'package:flutter/material.dart';
import 'package:health_assistant/views/ai/weekly_summary_screen.dart';

class ViewSummaryButton extends StatelessWidget {
  const ViewSummaryButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: scheme.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const WeeklySummaryScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              'VIEW WEEKLY SUMMARY',
              style: tt.labelLarge?.copyWith(
                color: scheme.onPrimary,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}