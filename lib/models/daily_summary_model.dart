import 'meal_model.dart';

class DailySummaryModel {
  final DateTime date; // ← أضفنا دي
  final int totalCalories;
  final int calorieGoal;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final List<MealModel> meals;

  DailySummaryModel({
    required this.date, // ← أضفنا دي
    required this.totalCalories,
    required this.calorieGoal,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.meals,
  });

  double get calorieProgress => totalCalories / calorieGoal;

  String get dateLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  factory DailySummaryModel.fromJson(Map<String, dynamic> json) =>
      DailySummaryModel(
        date: DateTime.parse(json['date']), // ← أضفنا دي
        totalCalories: json['total_calories'],
        calorieGoal: json['calorie_goal'],
        totalProtein: (json['total_protein'] as num).toDouble(),
        totalCarbs: (json['total_carbs'] as num).toDouble(),
        totalFat: (json['total_fat'] as num).toDouble(),
        meals: (json['meals'] as List)
            .map((m) => MealModel.fromJson(m))
            .toList(),
      );
}
