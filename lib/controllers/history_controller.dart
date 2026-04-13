import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../models/daily_summary_model.dart';
import '../services/meal_service.dart';

enum HistoryFilter { today, week, month }

class HistoryController extends ChangeNotifier {
  final MealService _mealService;
  HistoryController(this._mealService);

  HistoryFilter filter = HistoryFilter.today;
  List<DailySummaryModel> summaries = [];
  bool isLoading = false;
  String? error;
  String searchQuery = '';

  Future<void> loadHistory() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      // ── Dummy data للـ UI ─────────────────────────────────────────────
      // لما الـ backend يكون جاهز، شيلي السطر ده:
      // summaries = _dummyData();
      // وفكي التعليق عن السطرين دول:
      // final meals = await _mealService.getMealHistory();
      // summaries = _groupByDay(meals);
      summaries = _dummyData();
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

  List<DailySummaryModel> _dummyData() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    return [
      DailySummaryModel(
        date: DateTime(now.year, now.month, now.day),
        totalCalories: 1420,
        calorieGoal: 2000,
        totalProtein: 53,
        totalCarbs: 57,
        totalFat: 30,
        meals: [
          MealModel(
            id: '1',
            name: 'Grilled Salmon & Avocado',
            calories: 540,
            protein: 38,
            carbs: 12,
            fat: 22,
            loggedAt: DateTime(now.year, now.month, now.day, 12, 30),
          ),
          MealModel(
            id: '2',
            name: 'Berry Blast Smoothie Bowl',
            calories: 320,
            protein: 15,
            carbs: 45,
            fat: 8,
            loggedAt: DateTime(now.year, now.month, now.day, 8, 15),
          ),
        ],
      ),
      DailySummaryModel(
        date: DateTime(yesterday.year, yesterday.month, yesterday.day),
        totalCalories: 2105,
        calorieGoal: 2000,
        totalProtein: 32,
        totalCarbs: 72,
        totalFat: 18,
        meals: [
          MealModel(
            id: '3',
            name: 'Spicy Ahi Poke Bowl',
            calories: 680,
            protein: 32,
            carbs: 72,
            fat: 18,
            loggedAt: DateTime(
              yesterday.year,
              yesterday.month,
              yesterday.day,
              19,
              30,
            ),
          ),
        ],
      ),
    ];
  }

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
        calorieGoal: 2000,
        totalProtein: dayMeals.fold(0.0, (sum, m) => sum + m.protein),
        totalCarbs: dayMeals.fold(0.0, (sum, m) => sum + m.carbs),
        totalFat: dayMeals.fold(0.0, (sum, m) => sum + m.fat),
        meals: dayMeals,
      );
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }
}
