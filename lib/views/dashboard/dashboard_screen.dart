// Dashboard screen — the primary home view of the SnackTrack app.
//
// ## What changed in this file
// - `loadSummary()` now takes the current `SettingController` (read via
//   Provider) so the controller can use real goal values instead of a
//   hardcoded 2200/default.
// - The mock-data fallback is gone from the controller, so this screen
//   now needs to handle a real error state (previously `summary` was
//   never actually null on failure, since the controller always
//   substituted mock data).
// - Smart Analysis Card text now comes from
//   `controller.dietaryTip` (real AI call once ≥2 meals are logged)
//   instead of a hardcoded string. Falls back to a neutral placeholder
//   while the tip is loading or hasn't been generated yet.
// - Added a small active-streak indicator using `controller.activeStreak`.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/dashboard_controller.dart';
import '../../controllers/setting_controller.dart';
import '../../controllers/water_controller.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/loading_overlay.dart';
import 'widgets/calorie_ring_widget.dart';
import 'widgets/daily_log_item.dart';
import 'widgets/macro_card.dart';
import 'widgets/smart_analysis_card.dart';
import 'widgets/water_tracker_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final settings = context.read<SettingController>();
    context.read<DashboardController>().loadSummary(settings);
    context.read<WaterController>().loadToday();
  }

  void _showWaterOptions(BuildContext context) {
    final waterCtrl = context.read<WaterController>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log Water', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            _WaterAmountButton(ml: 200, label: 'Small glass (200ml)', icon: Icons.water_drop_outlined, onTap: () { waterCtrl.logWater(200); Navigator.pop(ctx); }),
            const SizedBox(height: 10),
            _WaterAmountButton(ml: 350, label: 'Medium glass (350ml)', icon: Icons.water_drop_outlined, onTap: () { waterCtrl.logWater(350); Navigator.pop(ctx); }),
            const SizedBox(height: 10),
            _WaterAmountButton(ml: 500, label: 'Large bottle (500ml)', icon: Icons.water_drop_outlined, onTap: () { waterCtrl.logWater(500); Navigator.pop(ctx); }),
            const SizedBox(height: 10),
            _WaterAmountButton(ml: 1000, label: 'Full liter (1000ml)', icon: Icons.water_drop_outlined, onTap: () { waterCtrl.logWater(1000); Navigator.pop(ctx); }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // ── Loading state ──────────────────────────────────────────────────
    if (controller.isLoading) {
      return const LoadingOverlay(isLoading: true, child: SizedBox.expand());
    }

    // ── Error state ────────────────────────────────────────────────────
    // Previously the controller always substituted mock data on error,
    // so `summary` was never actually null here. Now a real failure
    // (bad query, permissions, network) surfaces as an actual error
    // with a retry button instead of silently showing fake numbers.
    if (controller.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: scheme.error.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                controller.error!,
                textAlign: TextAlign.center,
                style: tt.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final summary = controller.summary;
    final settings = context.read<SettingController>();
    if (summary == null) {
      return Center(child: Text('No data available', style: tt.bodyLarge));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // ── Active streak ────────────────────────────────────────────
          if (controller.activeStreak != null && controller.activeStreak! > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.local_fire_department_rounded,
                      color: scheme.secondary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${controller.activeStreak}-day streak',
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

          // ── 1. Calorie ring ───────────────────────────────────────────
          CalorieRingWidget(
            consumed: summary.totalCalories,
            exercise: summary.exerciseCalories,
            goal: summary.calorieGoal,
          ),

          const SizedBox(height: 28),

          // ── 2. Macro-nutrient cards (protein · carbs · fats) ──────────
          Row(
            children: [
              Expanded(
                child: MacroCard(
                  label: 'PROTEIN',
                  value: '${summary.totalProtein.round()}g',
                  progress: summary.totalProtein / summary.proteinGoal,
                  color: scheme.primary,
                  iconAsset: 'assets/images/protein.png',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MacroCard(
                  label: 'CARBS',
                  value: '${summary.totalCarbs.round()}g',
                  progress: summary.totalCarbs / summary.carbsGoal,
                  color: scheme.tertiary,
                  iconAsset: 'assets/images/carbs.png',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MacroCard(
                  label: 'FATS',
                  value: '${summary.totalFat.round()}g',
                  progress: summary.totalFat / summary.fatGoal,
                  color: scheme.secondary,
                  iconAsset: 'assets/images/fats.png',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── 3. Water tracker ────────────────────────────────────────────
          WaterTrackerWidget(
            currentMl: context.watch<WaterController>().todayTotalMl,
            goalMl: settings.goalWaterMl,
            onAdd: () => _showWaterOptions(context),
            onDelete: null,
          ),

          const SizedBox(height: 20),

          // ── 4. Smart Analysis card ─────────────────────────────────────
          // Real AI tip once ≥2 meals are logged (handled in the
          // controller); shows a neutral placeholder otherwise so the
          // card doesn't look broken before enough data exists.
          SmartAnalysisCard(
            text: controller.dietaryTip ??
                (summary.meals.length < 2
                    ? 'Log a couple more meals today to unlock a personalized tip.'
                    : 'Generating your personalized tip…'),
          ),

          const SizedBox(height: 28),

          // ── 5. Daily Log header ────────────────────────────────────────
          Text(
            'Daily Log',
            style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),

          // ── 5. Meal entries with timeline ──────────────────────────────
          ...List.generate(summary.meals.length, (i) {
            final meal = summary.meals[i];
            return DailyLogItem(
              mealType: meal.type,
              foodName: meal.name,
              calories: meal.calories,
              loggedAt: meal.loggedAt,
              isLast: i == summary.meals.length - 1,
            );
          }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _WaterAmountButton extends StatelessWidget {
  final int ml;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _WaterAmountButton({
    required this.ml,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: colors.primary, size: 22),
            const SizedBox(width: 12),
            Text(label, style: theme.textTheme.labelLarge),
            const Spacer(),
            Icon(Icons.add_circle_outline, color: colors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
