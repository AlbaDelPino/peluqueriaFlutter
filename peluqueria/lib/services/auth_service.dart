import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Al estar en Windows Desktop, localhost funciona.
  // Si pasas a un emulador de Android, recuerda cambiarlo a 10.0.2.2
  final String baseUrl = 'http://10.50.183.95:8082/api/auth';

  // CONFIGURACIÓN PARA WINDOWS:
  // Debes poner aquí el "ID de cliente" de tipo "Web" que creaste en Google Cloud/Firebase.
  // Es necesario porque en Windows el plugin no detecta el archivo google-services.json de Android.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '1008130346590-ltepl35eg0i3eqkakv42k5l7igqfe1ru.apps.googleusercontent.com',
  );

  /// Login tradicional con usuario y contraseña
  Future<String?> intentarLogin(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/signin'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username.trim(),
              'contrasenya': password.trim(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 ? response.body : "CREDENCIALES_MAL";
    } catch (e) {
      print("Error Login: $e");
      return "ERROR_CONEXION";
    }
  }

  /// Inicio de sesión con Google
  Future<String?> iniciarSesionConGoogle() async {
    try {
      // Limpiamos sesión previa para que siempre pida elegir cuenta
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      // Abrir el flujo de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("El usuario canceló el inicio de sesión");
        return null;
      }

      // Enviar datos al backend para registrar o loguear al usuario
      final response = await http
          .post(
            Uri.parse('$baseUrl/google'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "email": googleUser.email,
              "nombre": googleUser.displayName ?? "Usuario",
              "username": googleUser.email.split('@')[0],
              "imagen": googleUser.photoUrl ?? "",
              "googleId": googleUser.id,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return response
            .body; // Devolvemos el JSON con el Token y datos del usuario
      } else {
        print("Error Servidor Google Login: ${response.statusCode}");
        return "ERROR_SERVIDOR";
      }
    } catch (e) {
      print("Error crítico Google Sign-In: $e");
      return "ERROR_CONEXION";
    }
  }
}
