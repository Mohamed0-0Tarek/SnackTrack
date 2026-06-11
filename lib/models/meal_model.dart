/// Represents a single meal entry with nutritional data and metadata.
///
/// ## Why immutable models?
/// All fields are declared `final`, making this class **immutable**.
/// Once created, a [MealModel] can never be changed — you must build
/// a new instance instead.  This prevents accidental side-effects
/// (e.g. one widget silently editing a model another widget is reading)
/// and makes state management with Provider much safer.
///
/// ## JSON round-tripping
/// [fromJson] creates a model from a `Map` (typically decoded from HTTP
/// response JSON), while [toJson] converts it back for API requests.
/// The `as num` casts in [fromJson] are intentional: JSON numbers may
/// arrive as either `int` or `double`, and `num` covers both before
/// calling `.toDouble()`.
class MealModel {
  /// Unique server-assigned identifier.
  final String   id;

  /// Descriptive food name (e.g. "Oatmeal & Berries").
  final String   name;

  /// Meal category — "breakfast", "lunch", "dinner", or "snack".
  ///
  /// Defaults to `'snack'` so existing code that creates a [MealModel]
  /// without specifying [type] still works (backward-compatible).
  final String   type;

  /// Total kilocalories for this meal.
  final int      calories;

  /// Grams of protein.
  final double   protein;

  /// Grams of carbohydrates.
  final double   carbs;

  /// Grams of fat.
  final double   fat;

  /// Timestamp when the meal was logged by the user.
  final DateTime loggedAt;

  /// Optional URL or local asset path for the meal photo.
  ///
  /// Nullable because not every meal has a photo — the UI shows a
  /// gradient placeholder when this is `null` (see [MealHistoryCard]).
  final String?  imageUrl;

  /// How the meal was prepared — "Restaurant", "Homemade", "Delivery", etc.
  ///
  /// Also nullable; the UI simply omits the source badge when absent.
  final String?  source;

  /// Creates a [MealModel].
  ///
  /// [id], [name], [calories], [protein], [carbs], [fat], and [loggedAt]
  /// are required.  [type] defaults to `'snack'`.  [imageUrl] and [source]
  /// are optional.
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
  });

  /// Constructs a [MealModel] from a decoded JSON map.
  ///
  /// The `??` operators provide safe defaults for fields that might be
  /// missing in older API responses, ensuring backward compatibility.
  factory MealModel.fromJson(Map<String, dynamic> json) => MealModel(
    id:       json['id'],
    name:     json['name'],
    type:     json['type'] ?? 'snack',
    calories: json['calories'],
    // `as num` handles both int and double from JSON decoders
    protein:  (json['protein'] as num).toDouble(),
    carbs:    (json['carbs']   as num).toDouble(),
    fat:      (json['fat']     as num).toDouble(),
    loggedAt: DateTime.parse(json['logged_at']),
    imageUrl: json['image_url'],
    source:   json['source'],
  );

  /// Serialises this model to a JSON-encodable map for API requests.
  ///
  /// The `if (x != null)` syntax is a Dart **collection-if**: the entry
  /// is only included in the map when the value is non-null, keeping the
  /// payload minimal.
  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'type': type, 'calories': calories,
    'protein': protein, 'carbs': carbs, 'fat': fat,
    'logged_at': loggedAt.toIso8601String(),
    if (imageUrl != null) 'image_url': imageUrl,
    if (source != null) 'source': source,
  };
}
