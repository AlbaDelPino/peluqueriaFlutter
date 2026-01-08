import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Tu IP local y el puerto de Spring Boot
  final String urlSignIn = 'http://10.103.246.95:8082/api/auth/signin';

  Future<String?> intentarLogin(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(urlSignIn),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username.trim(),
          'contrasenya': password.trim(),
        }),
      );

      if (response.statusCode == 200) {
        // ÉXITO: Devolvemos el JSON completo (trae nombre, token, etc.)
        return response.body;
      } else if (response.statusCode == 401) {
        return "CREDENCIALES_MAL";
      } else {
        return "ERROR_SERVIDOR";
      }
    } catch (e) {
      print("Error de conexión: $e");
      return "ERROR_CONEXION";
    }
  }
}
