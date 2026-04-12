class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:        json['id'],
    name:      json['name'],
    email:     json['email'],
    avatarUrl: json['avatar_url'],
    token:     json['token'],
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email,
    'avatar_url': avatarUrl, 'token': token,
  };
}
