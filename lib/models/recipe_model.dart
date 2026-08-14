import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel {
  final String id;
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<String> ingredients;
  final List<String> steps;
  final int servings;
  final int? prepTime;
  final String? imageUrl;
  final DateTime createdAt;

  RecipeModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
    required this.steps,
    required this.servings,
    this.prepTime,
    this.imageUrl,
    required this.createdAt,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) => RecipeModel(
    id:          json['id'] ?? '',
    name:        json['name'] ?? '',
    calories:    (json['calories'] as num?)?.toInt() ?? 0,
    protein:     (json['protein'] as num?)?.toDouble() ?? 0,
    carbs:       (json['carbs']   as num?)?.toDouble() ?? 0,
    fat:         (json['fat']     as num?)?.toDouble() ?? 0,
    ingredients: json['ingredients'] != null ? List<String>.from(json['ingredients']) : [],
    steps:       json['steps'] != null ? List<String>.from(json['steps']) : [],
    servings:    (json['servings'] as num?)?.toInt() ?? 1,
    prepTime:    (json['prepTime'] as num?)?.toInt(),
    imageUrl:    json['imageUrl'],
    createdAt:   DateTime.now(),
  );

  factory RecipeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final createdAtRaw = data['createdAt'];
    return RecipeModel(
      id:          doc.id,
      name:        data['name'] ?? '',
      calories:    (data['calories'] as num?)?.toInt() ?? 0,
      protein:     (data['protein'] as num?)?.toDouble() ?? 0,
      carbs:       (data['carbs']   as num?)?.toDouble() ?? 0,
      fat:         (data['fat']     as num?)?.toDouble() ?? 0,
      ingredients: data['ingredients'] != null ? List<String>.from(data['ingredients']) : [],
      steps:       data['steps'] != null ? List<String>.from(data['steps']) : [],
      servings:    (data['servings'] as num?)?.toInt() ?? 1,
      prepTime:    (data['prepTime'] as num?)?.toInt(),
      imageUrl:    data['imageUrl'],
      createdAt:   createdAtRaw is Timestamp ? createdAtRaw.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestoreMap() => {
    'name':        name,
    'calories':    calories,
    'protein':     protein,
    'carbs':       carbs,
    'fat':         fat,
    'ingredients': ingredients,
    'steps':       steps,
    'servings':    servings,
    if (prepTime != null) 'prepTime': prepTime,
    if (imageUrl != null) 'imageUrl': imageUrl,
    'createdAt':   FieldValue.serverTimestamp(),
  };
}
