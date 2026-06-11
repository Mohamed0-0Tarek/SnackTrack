class RecipeModel {
  final String id;
  final String name;
  final int    calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<String> ingredients;
  final List<String> steps;

  RecipeModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
    required this.steps,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) => RecipeModel(
    id:          json['id'],
    name:        json['name'],
    calories:    json['calories'],
    protein:     (json['protein'] as num).toDouble(),
    carbs:       (json['carbs']   as num).toDouble(),
    fat:         (json['fat']     as num).toDouble(),
    ingredients: List<String>.from(json['ingredients']),
    steps:       List<String>.from(json['steps']),
  );
}
