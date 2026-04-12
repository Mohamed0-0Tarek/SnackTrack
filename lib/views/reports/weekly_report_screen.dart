import 'package:flutter/material.dart';

class WeeklyReportScreen extends StatelessWidget {
  const WeeklyReportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reports', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 16),
              // TODO: add CaloriesLineChart, MacroDistributionChart, WeeklyAiSummaryCard
              const Center(child: Text('Weekly report coming soon')),
            ],
          ),
        ),
      ),
    );
  }
}
