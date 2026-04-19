import 'package:flutter/material.dart';

class SystemLogsCard extends StatelessWidget {
  const SystemLogsCard();

  static const _logs = [
    LogEntry(
      day: 'Mon',
      date: 'Oct 23',
      title: 'Perfect Macro Alignment',
      sub: 'All targets met within 2% margin.',
      score: 98,
      scoreHigh: true,
    ),
    LogEntry(
      day: 'Tue',
      date: 'Oct 24',
      title: 'Sodium Spike Detected',
      sub: 'Late-night intake exceeded threshold.',
      score: 72,
      scoreHigh: false,
    ),
    LogEntry(
      day: 'Wed',
      date: 'Oct 25',
      title: 'Recovery Optimization',
      sub: 'Protein synthesis peak observed during sleep.',
      score: 91,
      scoreHigh: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('System Logs', style: tt.headlineMedium),
        const SizedBox(height: 14),
        ..._logs.map(
          (log) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LogTile(entry: log),
          ),
        ),
      ],
    );
  }
}

class LogEntry {
  final String day, date, title, sub;
  final int score;
  final bool scoreHigh;

  const LogEntry({
    required this.day,
    required this.date,
    required this.title,
    required this.sub,
    required this.score,
    required this.scoreHigh,
  });
}

class LogTile extends StatelessWidget {
  final LogEntry entry;
  const LogTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scoreColor = entry.scoreHigh ? scheme.primary : Colors.red.shade400;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: isDark
            ? null
            : [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 6)],
      ),
      child: Row(
        children: [
          // Date column
          Column(
            children: [
              Text(
                entry.day,
                style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(entry.date, style: tt.labelSmall),
            ],
          ),
          // Vertical divider line
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            width: 2,
            height: 48,
            decoration: BoxDecoration(
              color: scoreColor.withAlpha(120),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(entry.sub, style: tt.bodySmall),
              ],
            ),
          ),
          // Score
          Text(
            '${entry.score}',
            style: tt.headlineMedium?.copyWith(
              color: scoreColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
