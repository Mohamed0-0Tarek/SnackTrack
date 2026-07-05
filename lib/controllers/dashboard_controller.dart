import 'package:flutter/material.dart';
import '../models/daily_summary_model.dart';
import '../services/meal_service.dart';
import '../services/ai_service.dart';
import 'setting_controller.dart';

/// Controller responsible for loading and exposing the daily nutritional
/// summary to the dashboard UI.
///
/// ## What changed vs the previous version
/// - `loadSummary()` no longer falls back to `_mockSummary` on error.
///   That fallback was useful while MealService was a non-functional
///   stub, but now that `getDailySummary()` is real, a failure here is
///   a genuine bug (bad query, permissions, network) — silently
///   substituting fake data would hide that instead of surfacing it.
///   Errors now set [error] for the UI to display with a retry option.
/// - Goals (`calorieGoal`/`proteinGoal`/`carbsGoal`/`fatGoal`) now come
///   from [SettingController] instead of a hardcoded `2200`/defaults.
///   `loadSummary()` takes the current `SettingController` as a
///   parameter rather than holding a reference to it directly, since
///   Provider's `context.read<SettingController>()` is the natural way
///   to get the latest values at call time without this controller
///   needing to listen to Settings changes itself.
/// - Added [loadDietaryTip] — calls `AiService.getDietaryTip()` once at
///   least 2 meals are logged today, and caches the result so it isn't
///   re-requested on every rebuild (matches the original plan's
///   "cache result to avoid repeated calls" requirement).
/// - Added [activeStreak] — counts consecutive days (most recent first)
///   with at least one logged meal, using `MealService.getMealHistory()`
///   as the data source.
class DashboardController extends ChangeNotifier {
  final MealService _mealService;
  final AiService _aiService;

  DashboardController(this._mealService, this._aiService);

  /// The current day's nutritional summary.
  /// Starts as `null` and is populated after [loadSummary] completes.
  DailySummaryModel? summary;

  bool isLoading = false;
  String? error;

  /// AI dietary tip for the Smart Analysis Card. Null until enough
  /// meals are logged today and the AI call has completed at least once.
  String? dietaryTip;
  bool isTipLoading = false;

  /// Consecutive days (including today, if it has meals) with at least
  /// one logged meal. Null until [loadActiveStreak] completes.
  int? activeStreak;

  /// Fetches today's nutritional summary from Firestore, using real
  /// goals from [settings]. Pass the current `SettingController`
  /// (e.g. via `context.read<SettingController>()`) — this controller
  /// doesn't hold its own reference so it stays decoupled from exactly
  /// when/how Settings notifies, and always uses whatever values are
  /// current at the moment this is called.
  Future<void> loadSummary(SettingController settings) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final raw = await _mealService.getDailySummary(DateTime.now());
      // Re-apply real goals on top of whatever MealService computed —
      // getDailySummary() aggregates totals correctly but doesn't know
      // about per-user settings, so the goal fields get overridden here.
      summary = DailySummaryModel(
        date: raw.date,
        totalCalories: raw.totalCalories,
        calorieGoal: settings.goalCalories,
        exerciseCalories: raw.exerciseCalories,
        totalProtein: raw.totalProtein,
        totalCarbs: raw.totalCarbs,
        totalFat: raw.totalFat,
        proteinGoal: settings.goalProtein,
        carbsGoal: settings.goalCarbs,
        fatGoal: settings.goalFat,
        meals: raw.meals,
      );
    } catch (e) {
      error = _describeError(e);
      summary = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }

    // Fire-and-forget: these don't block the main summary from
    // rendering, and each manages its own loading/error state.
    if (summary != null && summary!.meals.length >= 2) {
      loadDietaryTip();
    }
    loadActiveStreak();
  }

  /// Calls AiService for a one-tip dietary suggestion, only once at
  /// least 2 meals are logged today (per the original plan), and only
  /// if a tip hasn't already been loaded this session — avoids firing
  /// an AI request on every dashboard rebuild.
  Future<void> loadDietaryTip() async {
    if (dietaryTip != null || isTipLoading || summary == null) return;
    isTipLoading = true;
    notifyListeners();
    try {
      dietaryTip = await _aiService.getDietaryTip(summary!.meals);
    } catch (e) {
      // Non-critical — the card just won't show a tip this session.
      // Not setting `error` here since this shouldn't block/replace
      // the main dashboard error state.
    } finally {
      isTipLoading = false;
      notifyListeners();
    }
  }

  /// Counts consecutive days with at least one logged meal, starting
  /// from today and walking backward. Uses a bounded history fetch
  /// (90 days' worth via pageSize) rather than scanning the entire
  /// meal history, since a realistic streak is well under that.
  Future<void> loadActiveStreak() async {
    try {
      final meals = await _mealService.getMealHistory(pageSize: 500);
      final daysWithMeals = meals
          .map((m) => DateTime(m.loggedAt.year, m.loggedAt.month, m.loggedAt.day))
          .toSet();

      int streak = 0;
      var cursor = DateTime.now();
      cursor = DateTime(cursor.year, cursor.month, cursor.day);

      while (daysWithMeals.contains(cursor)) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      }

      activeStreak = streak;
      notifyListeners();
    } catch (e) {
      // Non-critical for the main dashboard render — leave activeStreak
      // null rather than surfacing a separate error state for this.
    }
  }

  String _describeError(Object e) {
    final raw = e.toString().replaceFirst('Exception: ', '');
    if (raw.length > 160) {
      return '${raw.substring(0, 160)}…';
    }
    return raw;
  }
}
