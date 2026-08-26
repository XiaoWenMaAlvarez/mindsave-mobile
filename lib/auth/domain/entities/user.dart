class User {
  final String id;
  final String email;
  final String name;
  final String password;
  final String token;

  const User({
    required this.email,
    required this.password,
    required this.id,
    required this.name,
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'id': id,
      'name': name,
      'token': token,
    };
  }

  factory User.fromObject(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      password: json['password'] ?? "",
      id: json['id'],
      name: json['name'],
      token: json['token'] ?? "",
    );
  }
}
