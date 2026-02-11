class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String? fullName;
  final int? age;
  final String? education;
  final DateTime createdAt;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.fullName,
    this.age,
    this.education,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'full_name': fullName,
      'age': age,
      'education': education,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      fullName: map['full_name'],
      age: map['age'],
      education: map['education'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    String? fullName,
    int? age,
    String? education,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      education: education ?? this.education,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
