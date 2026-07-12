import 'package:cloud_firestore/cloud_firestore.dart';

class PlannedMeal {
  final String mealType; // breakfast, lunch, dinner, snack
  final String name;
  final String? recipeId;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  PlannedMeal({
    required this.mealType,
    required this.name,
    this.recipeId,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toJson() => {
    'mealType': mealType,
    'name': name,
    if (recipeId != null) 'recipeId': recipeId,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
  };

  factory PlannedMeal.fromJson(Map<String, dynamic> json) => PlannedMeal(
    mealType: json['mealType'] ?? 'snack',
    name: json['name'] ?? '',
    recipeId: json['recipeId'],
    calories: (json['calories'] as num?)?.toInt() ?? 0,
    protein: (json['protein'] as num?)?.toDouble() ?? 0,
    carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
    fat: (json['fat'] as num?)?.toDouble() ?? 0,
  );
}

class MealPlanDay {
  final int dayOfWeek; // 1=Monday … 7=Sunday
  final List<PlannedMeal> meals;

  MealPlanDay({
    required this.dayOfWeek,
    required this.meals,
  });

  Map<String, dynamic> toJson() => {
    'dayOfWeek': dayOfWeek,
    'meals': meals.map((m) => m.toJson()).toList(),
  };

  factory MealPlanDay.fromJson(Map<String, dynamic> json) => MealPlanDay(
    dayOfWeek: (json['dayOfWeek'] as num?)?.toInt() ?? 1,
    meals: (json['meals'] as List?)
        ?.map((m) => PlannedMeal.fromJson(m as Map<String, dynamic>))
        .toList() ?? [],
  );

  static const dayNames = {
    1: 'Monday', 2: 'Tuesday', 3: 'Wednesday', 4: 'Thursday',
    5: 'Friday', 6: 'Saturday', 7: 'Sunday',
  };
}

class MealPlanModel {
  final String id;
  final String name;
  final List<MealPlanDay> days;
  final DateTime createdAt;

  MealPlanModel({
    required this.id,
    required this.name,
    required this.days,
    required this.createdAt,
  });

  factory MealPlanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final createdAtRaw = data['createdAt'];
    return MealPlanModel(
      id: doc.id,
      name: data['name'] ?? 'Meal Plan',
      days: (data['days'] as List?)
          ?.map((d) => MealPlanDay.fromJson(d as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: createdAtRaw is Timestamp ? createdAtRaw.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestoreMap() => {
    'name': name,
    'days': days.map((d) => d.toJson()).toList(),
    'createdAt': FieldValue.serverTimestamp(),
  };
}
