// Controller responsible for loading and exposing the daily nutritional
// summary to the dashboard UI.
//
// ## Architecture: Provider + ChangeNotifier
// This project uses the **Provider** package for state management.
// Each controller extends [ChangeNotifier] which gives it a
// `notifyListeners()` method.  When called, every widget that called
// `context.watch<DashboardController>()` rebuilds automatically.
//
// The controller is registered once in `app.dart` via:
//   ChangeNotifierProvider(create: (_) => DashboardController(mealService))
//
// ## Loading / error pattern
// Almost every controller follows the same three-phase pattern:
//   1. Set `isLoading = true` → notify → UI shows a spinner.
//   2. Await the async operation (API call).
//   3. Set `isLoading = false` in `finally` → notify → UI re-renders
//      with data or an error message.
//
// ## Mock data strategy
// During development the real API isn't available yet, so `loadSummary`
// catches errors and falls back to `_mockSummary`.  This lets the entire
// dashboard render immediately so designers and devs can iterate on UI
// without a running backend.
import 'package:flutter/material.dart';
import '../models/daily_summary_model.dart';
import '../models/meal_model.dart';
import '../services/meal_service.dart';

class DashboardController extends ChangeNotifier {
  /// Private reference to the data layer — injected via constructor so
  /// the controller is unit-testable (you can pass a mock service).
  final MealService _mealService;

  DashboardController(this._mealService);

  /// The current day's nutritional summary.
  ///
  /// Starts as `null` and is populated after [loadSummary] completes.
  /// Widgets should null-check before accessing fields.
  DailySummaryModel? summary;

  /// `true` while an API call is in-flight — the UI shows a loading
  /// overlay during this window.
  bool   isLoading = false;

  /// Human-readable error message set when the API call fails.
  /// The UI can display this in a snackbar or inline error widget.
  String? error;

  /// Fetches today's nutritional summary from the backend.
  ///
  /// ### Why `notifyListeners()` is called twice
  /// The first call (after setting `isLoading = true`) triggers the UI
  /// to show a spinner.  The second call (in `finally`) tells the UI
  /// "data is ready, rebuild with the new [summary]".
  ///
  /// ### Error recovery
  /// If the network call throws, we fall back to [_mockSummary] so the
  /// dashboard still renders.  In production you'd show an error banner
  /// instead and set `summary = null`.
  Future<void> loadSummary() async {
    isLoading = true; error = null; notifyListeners();
    try {
      summary = await _mealService.getDailySummary(DateTime.now());
    } catch (e) {
      // Fallback to hardcoded data during development
      summary = _mockSummary;
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  // ── Mock data used when the real API is unavailable ─────────────────────────
  //
  // `static` because mock data doesn't depend on instance state.
  // `get` (a getter) so a fresh object is built each time — prevents
  // accidental mutation of a shared reference.
  static DailySummaryModel get _mockSummary => DailySummaryModel(
    date: DateTime(2005),
    totalCalories:    1260,
    calorieGoal:      3100,
    exerciseCalories: 420,
    totalProtein:     92,
    totalCarbs:       145,
    totalFat:         48,
    proteinGoal:      127,
    carbsGoal:        200,
    fatGoal:          65,
    meals: [
      MealModel(
        id: '1',
        name: 'Oatmeal & Berries',
        type: 'breakfast',
        calories: 340,
        protein: 12,
        carbs: 58,
        fat: 8,
        loggedAt: DateTime(2026, 4, 13, 8, 30),
      ),
      MealModel(
        id: '2',
        name: 'Chicken Caesar Salad',
        type: 'lunch',
        calories: 520,
        protein: 45,
        carbs: 32,
        fat: 22,
        loggedAt: DateTime(2026, 4, 13, 13, 15),
      ),
      MealModel(
        id: '3',
        name: 'Apple & Almond Butter',
        type: 'snack',
        calories: 180,
        protein: 5,
        carbs: 24,
        fat: 9,
        loggedAt: DateTime(2026, 4, 13, 16, 45),
      ),
    ],
  );
}
