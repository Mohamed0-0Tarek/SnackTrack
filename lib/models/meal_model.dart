class MealModel {
  final String id;
  final String name;
  final int    calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime loggedAt;

  MealModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.loggedAt,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) => MealModel(
    id:       json['id'],
    name:     json['name'],
    calories: json['calories'],
    protein:  (json['protein'] as num).toDouble(),
    carbs:    (json['carbs']   as num).toDouble(),
    fat:      (json['fat']     as num).toDouble(),
    loggedAt: DateTime.parse(json['logged_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'calories': calories,
    'protein': protein, 'carbs': carbs, 'fat': fat,
    'logged_at': loggedAt.toIso8601String(),
  };
}
