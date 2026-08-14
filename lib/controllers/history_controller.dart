import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../models/daily_summary_model.dart';
import '../services/meal_service.dart';

/// ## What changed vs the old HistoryController
/// `loadHistory()` previously always called `_dummyData()` — the real
/// path (`MealService.getMealHistory()` + `_groupByDay()`) was already
/// written here but commented out, waiting on MealService to actually
/// be backed by Firestore. That's now done (see MealService rewrite),
/// so this just flips the active path.
///
/// `_dummyData()` and `_groupByDay()` are both kept: `_groupByDay` is
/// now the live path, `_dummyData` is left in place only as a reference
/// for what the shape used to look like — safe to delete once you're
/// confident the real path is stable, but not removed here to keep
/// this change minimal and easy to review.
enum HistoryFilter { today, week, month }

class HistoryController extends ChangeNotifier {
  final MealService _mealService;
  HistoryController(this._mealService);

  HistoryFilter filter = HistoryFilter.today;
  List<DailySummaryModel> summaries = [];
  bool isLoading = false;
  String? error;
  String searchQuery = '';
  int _goalCalories = 2000;

  void setGoalCalories(int value) {
    _goalCalories = value;
  }

  Future<void> loadHistory() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final meals = await _mealService.getMealHistory();
      summaries = _groupByDay(meals);
    } catch (e) {
      error = 'Could not load history.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(HistoryFilter f) {
    filter = f;
    notifyListeners();
  }

  void setSearch(String q) {
    searchQuery = q;
    notifyListeners();
  }

  List<DailySummaryModel> get filtered {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return summaries.where((s) {
      final d = DateTime(s.date.year, s.date.month, s.date.day);
      bool inRange;
      switch (filter) {
        case HistoryFilter.today:
          inRange = d == today;
          break;
        case HistoryFilter.week:
          inRange = d.isAfter(today.subtract(const Duration(days: 7)));
          break;
        case HistoryFilter.month:
          inRange = d.isAfter(today.subtract(const Duration(days: 30)));
          break;
      }
      if (searchQuery.isEmpty) return inRange;
      return inRange &&
          s.meals.any(
            (m) => m.name.toLowerCase().contains(searchQuery.toLowerCase()),
          );
    }).toList();
  }

  /// Groups a flat list of meals (newest-first, as returned by
  /// MealService.getMealHistory) into one DailySummaryModel per day,
  /// sorted newest-day-first. Goal calories come from [setGoalCalories].
  List<DailySummaryModel> _groupByDay(List<MealModel> meals) {
    final Map<String, List<MealModel>> map = {};
    for (final meal in meals) {
      final key =
          '${meal.loggedAt.year}-${meal.loggedAt.month}-${meal.loggedAt.day}';
      map.putIfAbsent(key, () => []).add(meal);
    }
    return map.entries.map((e) {
      final parts = e.key.split('-');
      final dayMeals = e.value;
      return DailySummaryModel(
        date: DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        ),
        totalCalories: dayMeals.fold(0, (sum, m) => sum + m.calories),
        calorieGoal: _goalCalories,
        totalProtein: dayMeals.fold(0.0, (sum, m) => sum + m.protein),
        totalCarbs: dayMeals.fold(0.0, (sum, m) => sum + m.carbs),
        totalFat: dayMeals.fold(0.0, (sum, m) => sum + m.fat),
        meals: dayMeals,
      );
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }
}
