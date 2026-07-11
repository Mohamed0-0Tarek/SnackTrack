import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single logged meal.
///
/// ## What changed vs the old MealModel
/// Added [notes] and [analyzedBy] — both are in the agreed Firestore
/// schema (`users/{uid}/meals/{mealId}`) but were missing here, which
/// would have caused silent data loss the moment MealService started
/// writing real documents.
///
/// Also added [fromFirestore] / [toFirestoreMap], which work with
/// Firestore's `Timestamp` type instead of ISO date strings. The old
/// [fromJson]/[toJson] are kept as-is so nothing that already calls them
/// breaks — they're just no longer the primary path for persistence.
class MealModel {
  final String id;
  final String name;
  final String type;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime loggedAt;
  final String? imageUrl;
  final String? source;
  final String? notes;
  final String? analyzedBy; // e.g. "gemini-1.5", "manual", "favorite"
  final Map<String, double>? vitamins; // e.g. {"Vitamin A": 0.85, "Vitamin C": 0.42}
  final Map<String, double>? minerals; // e.g. {"Iron": 0.28, "Magnesium": 0.55}

  MealModel({
    required this.id,
    required this.name,
    this.type = 'snack',
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.loggedAt,
    this.imageUrl,
    this.source,
    this.notes,
    this.analyzedBy,
    this.vitamins,
    this.minerals,
  });

  /// Old JSON path — kept for any code still using REST-style payloads.
  factory MealModel.fromJson(Map<String, dynamic> json) => MealModel(
        id: json['id'],
        name: json['name'],
        type: json['type'] ?? 'snack',
        calories: json['calories'],
        protein: (json['protein'] as num).toDouble(),
        carbs: (json['carbs'] as num).toDouble(),
        fat: (json['fat'] as num).toDouble(),
        loggedAt: DateTime.parse(json['logged_at']),
        imageUrl: json['image_url'],
        source: json['source'],
        notes: json['notes'],
        analyzedBy: json['analyzed_by'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'logged_at': loggedAt.toIso8601String(),
        if (imageUrl != null) 'image_url': imageUrl,
        if (source != null) 'source': source,
        if (notes != null) 'notes': notes,
        if (analyzedBy != null) 'analyzed_by': analyzedBy,
      };

  /// Builds a MealModel from a Firestore document snapshot.
  /// `loggedAt` arrives as a Firestore [Timestamp], not a string.
  factory MealModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final loggedAtRaw = data['loggedAt'];
    return MealModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? 'snack',
      calories: (data['calories'] as num?)?.toInt() ?? 0,
      protein: (data['protein'] as num?)?.toDouble() ?? 0,
      carbs: (data['carbs'] as num?)?.toDouble() ?? 0,
      fat: (data['fat'] as num?)?.toDouble() ?? 0,
      loggedAt: loggedAtRaw is Timestamp
          ? loggedAtRaw.toDate()
          : DateTime.now(),
      imageUrl: data['imageUrl'],
      source: data['source'],
      notes: data['notes'],
      analyzedBy: data['analyzedBy'],
      vitamins: data['vitamins'] != null
          ? Map<String, double>.from(
              (data['vitamins'] as Map).map((k, v) => MapEntry(k, (v as num).toDouble())),
            )
          : null,
      minerals: data['minerals'] != null
          ? Map<String, double>.from(
              (data['minerals'] as Map).map((k, v) => MapEntry(k, (v as num).toDouble())),
            )
          : null,
    );
  }

  /// Serializes for a Firestore write. Does NOT include `id` (Firestore
  /// generates/uses the doc ID separately) and uses [FieldValue
  /// .serverTimestamp] for new writes — callers that need an exact local
  /// DateTime to send (e.g. updates) can use [toFirestoreMapWithDate]
  /// instead.
  Map<String, dynamic> toFirestoreMap({bool useServerTimestamp = true}) => {
        'name': name,
        'type': type,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'loggedAt': useServerTimestamp
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(loggedAt),
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (source != null) 'source': source,
        if (notes != null) 'notes': notes,
        if (analyzedBy != null) 'analyzedBy': analyzedBy,
        if (vitamins != null) 'vitamins': vitamins,
        if (minerals != null) 'minerals': minerals,
      };
}
