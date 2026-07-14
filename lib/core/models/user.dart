class User {
  final String id;
  final String name;
  final String email;
  final String? password;
  final String? profileImagePath;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    this.profileImagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'profileImagePath': profileImagePath,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      profileImagePath: json['profileImagePath'] ?? '',
    );
  }

  User copyWith({
    String? name,
    String? email,
    String? password,
    String? profileImagePath,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
