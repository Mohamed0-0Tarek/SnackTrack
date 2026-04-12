import 'meal_model.dart';

class DailySummaryModel {
  final int    totalCalories;
  final int    calorieGoal;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final List<MealModel> meals;

  DailySummaryModel({
    required this.totalCalories,
    required this.calorieGoal,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.meals,
  });

  double get calorieProgress => totalCalories / calorieGoal;

  factory DailySummaryModel.fromJson(Map<String, dynamic> json) => DailySummaryModel(
    totalCalories: json['total_calories'],
    calorieGoal:   json['calorie_goal'],
    totalProtein:  (json['total_protein'] as num).toDouble(),
    totalCarbs:    (json['total_carbs']   as num).toDouble(),
    totalFat:      (json['total_fat']     as num).toDouble(),
    meals: (json['meals'] as List).map((m) => MealModel.fromJson(m)).toList(),
  );
}
