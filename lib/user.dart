class User {
  final int id;
  final String username;
  final String email;

  User({
    required this.id,
    required this.username,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print("📌 User JSON Data: $json");

    return User(
      id: json['id'] is int ? json['id'] : 0, // `id`가 없으면 기본값 0
      username: json['username'] ?? 'Unknown',
      email: json['email'] ?? 'Unknown',
    );
  }
}
