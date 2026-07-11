import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/setting_controller.dart';
import '../../controllers/weekly_report_controller.dart';
import 'widgets/caloric_flux_card.dart';
import 'widgets/header.dart';
import 'widgets/macro_integrity_card.dart';
import 'widgets/oracle_card.dart';
import 'widgets/stats_grid.dart';
import 'widgets/view_summary_button.dart';

/// ## What changed in this file
/// Was fully static — every card (`CaloricFluxCard`, `MacroIntegrityCard`,
/// `OracleCard`, `StatsGrid`) was a `const` widget with hardcoded data.
/// Now reads from `WeeklyReportController` which fetches real 7-day
/// Firestore data and calls the AI oracle.
class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeeklyReportController>().loadReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WeeklyReportController>();
    final settings = context.watch<SettingController>();
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (controller.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48, color: scheme.error.withValues(alpha: 0.6)),
              const SizedBox(height: 16),
              Text(controller.error!, textAlign: TextAlign.center,
                  style: tt.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.loadReport(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final report = controller.report;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Header(),
              const SizedBox(height: 20),

              // Caloric trend chart — real 7-day data
              CaloricFluxCard(
                dailyCalories: report?.dailyCalories ??
                    List.filled(7, 0),
                days: _dayLabels(),
                goalCalories: settings.goalCalories,
              ),
              const SizedBox(height: 14),

              // Macro donut — real macro split
              MacroIntegrityCard(
                macroPercentages:
                    report?.macroPercentages ?? [0.33, 0.33, 0.34],
                totalProtein:
                    '${report?.totalProtein.toStringAsFixed(0) ?? '–'}g',
                totalCarbs:
                    '${report?.totalCarbs.toStringAsFixed(0) ?? '–'}g',
                totalFat:
                    '${report?.totalFat.toStringAsFixed(0) ?? '–'}g',
              ),
              const SizedBox(height: 14),

              // AI Oracle verdict — real grade + recommendations
              OracleCard(
                grade: controller.oracleGrade,
                summary: controller.oracleSummary,
                recommendations: controller.oracleRecs,
                isLoading: controller.isOracleLoading,
              ),
              const SizedBox(height: 14),

              // Stats grid — avg calories is real, rest stay placeholder
              // for now (hydration/sleep not tracked yet)
              StatsGrid(
                avgCalories: report?.avgCalories ?? 0,
              ),
              const SizedBox(height: 20),

              const ViewSummaryButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _dayLabels() {
    const labels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final today = DateTime.now().weekday; // 1=Mon … 7=Sun
    return List.generate(
        7, (i) => labels[(today - 7 + i) % 7]);
  }
}
