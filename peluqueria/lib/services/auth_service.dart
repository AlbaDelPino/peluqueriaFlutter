import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final String baseUrl = 'http://10.103.246.95:8082/api/auth';

  // Al haber corregido el ID del paquete en Gradle, 
  // el constructor simple debería dejar de salir en rojo.
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String?> intentarLogin(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username.trim(),
          'contrasenya': password.trim(),
        }),
      );
      return response.statusCode == 200 ? response.body : "CREDENCIALES_MAL";
    } catch (e) {
      return "ERROR_CONEXION";
    }
  }

  Future<String?> iniciarSesionConGoogle() async {
    try {
      // Intentamos cerrar sesión previa por si acaso
      try { await _googleSignIn.signOut(); } catch (_) {}

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return null; 

      final response = await http.post(
        Uri.parse('$baseUrl/google'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": googleUser.email,
          "nombre": googleUser.displayName ?? "Usuario",
          "username": googleUser.email.split('@')[0],
          "imagen": googleUser.photoUrl ?? "",
          "googleId": googleUser.id,
        }),
      );

      return response.statusCode == 200 ? response.body : "ERROR_SERVIDOR";
    } catch (e) {
      print("Error Google: $e");
      return "ERROR_CONEXION";
    }
  }
}