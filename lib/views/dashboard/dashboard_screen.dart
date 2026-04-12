import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/dashboard_controller.dart';
import '../../core/widgets/loading_overlay.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardController>().loadSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    if (controller.isLoading) return const LoadingOverlay(isLoading: true, child: SizedBox());
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good morning!', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text('Here\'s your daily summary', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              if (controller.summary != null) ...[
                Text('${controller.summary!.totalCalories} / ${controller.summary!.calorieGoal} kcal',
                    style: Theme.of(context).textTheme.displayMedium),
              ],
              // TODO: add CalorieRing, MacroCards, TodaysMeals widgets
            ],
          ),
        ),
      ),
    );
  }
}
