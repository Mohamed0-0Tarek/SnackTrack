// Dashboard screen — the primary home view of the SnackTrack app.
//
// ## Widget composition
// Rather than building the entire dashboard in one monolithic file,
// the UI is split into focused widget files under `widgets/`:
//   1. [CalorieRingWidget] — circular progress ring.
//   2. [MacroCard]         — protein / carbs / fats card (×3).
//   3. [SmartAnalysisCard] — AI dietary recommendation.
//   4. [DailyLogItem]      — single meal row with timeline.
//
// This screen just *composes* them inside a [SingleChildScrollView].
//
// ## StatefulWidget vs StatelessWidget
// We use [StatefulWidget] here solely because we need [initState] to
// kick off the data fetch.  The rest of the state lives in the
// [DashboardController] (a [ChangeNotifier] managed by Provider).
//
// ## `context.read` vs `context.watch`
// - `read` — fires once and doesn't listen.  Used in [initState]
//   callbacks (where you only want to trigger an action).
// - `watch` — subscribes to changes.  Used in [build] so the widget
//   rebuilds whenever the controller calls `notifyListeners()`.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/dashboard_controller.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/loading_overlay.dart';
import 'widgets/calorie_ring_widget.dart';
import 'widgets/daily_log_item.dart';
import 'widgets/macro_card.dart';
import 'widgets/smart_analysis_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // `addPostFrameCallback` ensures the widget tree is fully built
    // before we call `read`.  Calling `read` directly inside initState
    // can fail because the Provider hasn't finished mounting yet.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardController>().loadSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    // `watch` subscribes to [DashboardController] — every time it
    // calls `notifyListeners()`, this build method re-runs.
    final controller = context.watch<DashboardController>();
    final scheme     = Theme.of(context).colorScheme;
    final tt         = Theme.of(context).textTheme;

    // ── Loading state ──────────────────────────────────────────────────────────
    // Shows the branded pulsing logo overlay while the API call resolves.
    if (controller.isLoading) {
      return const LoadingOverlay(isLoading: true, child: SizedBox.expand());
    }

    // ── Empty / error state ────────────────────────────────────────────────────
    // If the controller couldn't load anything (and the mock also failed),
    // show a simple fallback message.
    final summary = controller.summary;
    if (summary == null) {
      return Center(
        child: Text('No data available', style: tt.bodyLarge),
      );
    }

    // ── Main scrollable content ────────────────────────────────────────────────
    // [SingleChildScrollView] wraps a single Column; for very long lists
    // you'd prefer `ListView.builder` for lazy rendering (see the history
    // screen for that approach).
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical:   AppDimensions.paddingSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // ── 1. Calorie ring ─────────────────────────────────────────────────
          // Passes raw data; the widget handles formatting & painting.
          CalorieRingWidget(
            consumed: summary.totalCalories,
            exercise: summary.exerciseCalories,
            goal:     summary.calorieGoal,
          ),

          const SizedBox(height: 28),

          // ── 2. Macro-nutrient cards (protein · carbs · fats) ────────────────
          // Three [MacroCard]s inside a [Row] with [Expanded] wrappers so
          // each card gets an equal share of the available width.
          Row(
            children: [
              // Protein — primary (cyan/teal) accent
              Expanded(
                child: MacroCard(
                  label:     'PROTEIN',
                  value:     '${summary.totalProtein.round()}g',
                  progress:  summary.totalProtein / summary.proteinGoal,
                  color:     scheme.primary,
                  iconAsset: 'assets/images/protein.png',
                ),
              ),
              const SizedBox(width: 10),

              // Carbs — tertiary (lavender/blue) accent
              Expanded(
                child: MacroCard(
                  label:     'CARBS',
                  value:     '${summary.totalCarbs.round()}g',
                  progress:  summary.totalCarbs / summary.carbsGoal,
                  color:     scheme.tertiary,
                  iconAsset: 'assets/images/carbs.png',
                ),
              ),
              const SizedBox(width: 10),

              // Fats — secondary (purple) accent
              Expanded(
                child: MacroCard(
                  label:     'FATS',
                  value:     '${summary.totalFat.round()}g',
                  progress:  summary.totalFat / summary.fatGoal,
                  color:     scheme.secondary,
                  iconAsset: 'assets/images/fats.png',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── 3. Smart Analysis card ──────────────────────────────────────────
          // Hard-coded text for now; in production this would come from
          // [AiController.latestAnalysis].
          const SmartAnalysisCard(
            text: 'You\'re nearing your carb limit but have 35g of protein to '
                  'spare. For dinner, consider a grilled salmon salad to hit '
                  'your macro targets!',
          ),

          const SizedBox(height: 28),

          // ── 4. Daily Log header ─────────────────────────────────────────────
          Text(
            'Daily Log',
            style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),

          // ── 5. Meal entries with timeline ───────────────────────────────────
          // The `...` (spread operator) inlines the generated list into the
          // Column's children.  `List.generate` creates one [DailyLogItem]
          // per meal, passing `isLast: true` for the final entry so the
          // timeline connector line is hidden.
          ...List.generate(summary.meals.length, (i) {
            final meal = summary.meals[i];
            return DailyLogItem(
              mealType: meal.type,
              foodName: meal.name,
              calories: meal.calories,
              loggedAt: meal.loggedAt,
              isLast:   i == summary.meals.length - 1,
            );
          }),

          // Extra bottom padding so the bottom-nav FAB doesn't overlap
          // the last meal card.
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
