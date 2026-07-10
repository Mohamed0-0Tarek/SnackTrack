import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/weekly_report_controller.dart';
import 'widgets/hero_header.dart';
import 'widgets/grade_card.dart';
import 'widgets/metabolic_health_card.dart';
import 'widgets/energy_flux_card.dart';
import 'widgets/nutrient_saturation_card.dart';
import 'widgets/oracle_verdict_card.dart';
import 'widgets/system_logs_card.dart';

class WeeklySummaryScreen extends StatefulWidget {
  const WeeklySummaryScreen({super.key});

  @override
  State<WeeklySummaryScreen> createState() => _WeeklySummaryScreenState();
}

class _WeeklySummaryScreenState extends State<WeeklySummaryScreen> {
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
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (controller.isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: scheme.error.withValues(alpha: 0.6)),
              const SizedBox(height: 16),
              Text(controller.error!, textAlign: TextAlign.center, style: tt.bodyMedium),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeroHeader(
                avgCalories: report?.avgCalories ?? 0,
                mealCount: report?.allMeals.length ?? 0,
              ),
              const SizedBox(height: 20),
              GradeCard(grade: controller.oracleGrade ?? 'B', progress: 0.92),
              const SizedBox(height: 14),
              MetabolicHealthCard(
                totalProtein: report?.totalProtein ?? 0,
                totalCarbs: report?.totalCarbs ?? 0,
                totalFat: report?.totalFat ?? 0,
              ),
              const SizedBox(height: 14),
              EnergyFluxCard(avgCalories: report?.avgCalories ?? 0),
              const SizedBox(height: 14),
              NutrientSaturationCard(report: report),
              const SizedBox(height: 14),
              OracleVerdictCard(
                summary: controller.oracleSummary,
                recommendations: controller.oracleRecs,
                isLoading: controller.isOracleLoading,
              ),
              const SizedBox(height: 14),
              SystemLogsCard(
                topMeal: report?.topMealByCalories?.name,
                streak: report?.allMeals.length ?? 0,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
