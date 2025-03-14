class User {
  final int id;
  final String username;
  final String email;

  User({required this.id, required this.username, required this.email});

  // Factory constructor to create a User from a map (parsed response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 'No ID', // id가 없으면 'No ID'로 처리
      username: json['username'] ?? 'Unknown', // username이 없으면 'Unknown'으로 처리
      email: json['email'] ?? 'Unknown', // email이 없으면 'Unknown'으로 처리
    );
  }
}
