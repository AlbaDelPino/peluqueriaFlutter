class LoginResponse {
  final String token;
  final int id;
  final String username;
  final String email;
  final List<String> roles;

  LoginResponse({
    required this.token,
    required this.id,
    required this.username,
    required this.email,
    required this.roles,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      id: json['id'],
      username: json['username'],
      email: json['email'],
      // Mapeamos la lista de roles correctamente
      roles: List<String>.from(json['roles']),
    );
  }
}
