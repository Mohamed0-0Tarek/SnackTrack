// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String token;
  final int activeStreak;
  final int entries;
  final String bio;
  
  // Onboarding fields (made nullable so they are safe before onboarding is finished)
  final int? age;
  final double? weight;
  final double? height;
  final String? objective; // e.g., 'loss weight', 'build muscle'

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

  // Factory to parse incoming API / Firestore JSON data
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

  // Convert model data into JSON format to write to Firestore
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
