import 'package:hive/hive.dart';

part 'user_model.g.dart';

/// Same UserModel as before — fromJson/toJson/copyWith are unchanged so
/// every existing call site (AuthController, ProfileController, etc.)
/// keeps working without edits. The only addition is Hive annotations so
/// StorageService can cache this object directly instead of as a raw Map.
///
/// typeId 0 — keep this distinct from SettingsModel's typeId 1.
///
/// NOTE: after adding this, run:
///   flutter packages pub run build_runner build
/// to generate user_model.g.dart.
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String avatarUrl;
  @HiveField(4)
  final String token;
  @HiveField(5)
  final int activeStreak;
  @HiveField(6)
  final int entries;
  @HiveField(7)
  final String bio;
  @HiveField(8)
  final int? age;
  @HiveField(9)
  final double? weight;
  @HiveField(10)
  final double? height;
  @HiveField(11)
  final String? objective;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.token,
    required this.activeStreak,
    required this.entries,
    required this.bio,
    this.age,
    this.weight,
    this.height,
    this.objective,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      token: json['token'] ?? '',
      activeStreak: json['activeStreak'] ?? 0,
      entries: json['entries'] ?? 0,
      bio: json['bio'] ?? '',
      age: json['age'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      objective: json['objective'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'activeStreak': activeStreak,
      'entries': entries,
      'bio': bio,
      if (age != null) 'age': age,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (objective != null) 'objective': objective,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? token,
    int? activeStreak,
    int? entries,
    String? bio,
    int? age,
    double? weight,
    double? height,
    String? objective,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      token: token ?? this.token,
      activeStreak: activeStreak ?? this.activeStreak,
      entries: entries ?? this.entries,
      bio: bio ?? this.bio,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      objective: objective ?? this.objective,
    );
  }
}
