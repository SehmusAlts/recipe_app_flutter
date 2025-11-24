class User {
  const User({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.createdAt,
  });

  final int id;
  final String username;
  final String email;
  final String? fullName;
  final DateTime? createdAt;

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      username: map['username'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

