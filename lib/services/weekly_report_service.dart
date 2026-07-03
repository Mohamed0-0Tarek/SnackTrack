import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/meal_model.dart';

/// Aggregated data for one day in the weekly report.
class DailyAggregate {
  final DateTime date;
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final int mealCount;

  const DailyAggregate({
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.mealCount,
  });
}

/// Fully aggregated weekly summary — what WeeklyReportController exposes
/// to the UI after processing raw meal data.
class WeeklyReport {
  /// One entry per day, sorted oldest → newest (Mon → Sun / today).
  final List<DailyAggregate> days;

  /// All meals from the 7-day window, flattened — used for AI analysis.
  final List<MealModel> allMeals;

  const WeeklyReport({required this.days, required this.allMeals});

  int get avgCalories {
    final activeDays = days.where((d) => d.mealCount > 0).toList();
    if (activeDays.isEmpty) return 0;
    return activeDays.fold(0, (s, d) => s + d.totalCalories) ~/ activeDays.length;
  }

  double get totalProtein =>
      days.fold(0.0, (s, d) => s + d.totalProtein);

  double get totalCarbs =>
      days.fold(0.0, (s, d) => s + d.totalCarbs);

  double get totalFat =>
      days.fold(0.0, (s, d) => s + d.totalFat);

  /// Macro percentages for the donut chart.
  /// Returns [proteinPct, carbsPct, fatPct] each in 0.0–1.0 range.
  List<double> get macroPercentages {
    final proteinCal = totalProtein * 4;
    final carbsCal = totalCarbs * 4;
    final fatCal = totalFat * 9;
    final total = proteinCal + carbsCal + fatCal;
    if (total == 0) return [0.33, 0.33, 0.34];
    return [proteinCal / total, carbsCal / total, fatCal / total];
  }

  /// The 7 daily calorie values in order, for the bar/line chart.
  List<int> get dailyCalories => days.map((d) => d.totalCalories).toList();

  MealModel? get topMealByCalories => allMeals.isEmpty
      ? null
      : allMeals.reduce((a, b) => a.calories >= b.calories ? a : b);
}

class WeeklyReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _requireUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('No signed-in user for WeeklyReportService.');
    return uid;
  }

  /// Fetches all meals from the last 7 days and aggregates them into a
  /// [WeeklyReport]. Returns one [DailyAggregate] per day (including
  /// days with zero meals so the chart always has 7 bars).
  Future<WeeklyReport> getWeeklyReport() async {
    final uid = _requireUid();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 6));

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('meals')
        .where('loggedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo))
        .orderBy('loggedAt')
        .get();

    final allMeals = snapshot.docs.map(MealModel.fromFirestore).toList();

    // Group meals by calendar day
    final Map<String, List<MealModel>> byDay = {};
    for (final meal in allMeals) {
      final key =
          '${meal.loggedAt.year}-${meal.loggedAt.month}-${meal.loggedAt.day}';
      byDay.putIfAbsent(key, () => []).add(meal);
    }

    // Build one aggregate per day in the 7-day window, including empty days
    final days = <DailyAggregate>[];
    for (int i = 0; i < 7; i++) {
      final date = weekAgo.add(Duration(days: i));
      final key = '${date.year}-${date.month}-${date.day}';
      final meals = byDay[key] ?? [];
      days.add(DailyAggregate(
        date: date,
        totalCalories: meals.fold(0, (s, m) => s + m.calories),
        totalProtein: meals.fold(0.0, (s, m) => s + m.protein),
        totalCarbs: meals.fold(0.0, (s, m) => s + m.carbs),
        totalFat: meals.fold(0.0, (s, m) => s + m.fat),
        mealCount: meals.length,
      ));
    }

    return WeeklyReport(days: days, allMeals: allMeals);
  }
}
