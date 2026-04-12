class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? token;
  final int? activeStreak;
  final int? entries ;
  final String? bio;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.token,
    this.activeStreak,
    this.entries,
    this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:        json['id'],
    name:      json['name'],
    email:     json['email'],
    avatarUrl: json['avatar_url'],
    token:     json['token'],
    activeStreak: json['active_streak'],
    entries: json['entries'],
    bio: json['bio'],
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email,
    'avatar_url': avatarUrl, 'token': token,
    'active_streak': activeStreak,
    'entries': entries,
    'bio': bio,
  };
}
