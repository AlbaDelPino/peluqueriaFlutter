import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final String baseUrl = 'http://192.168.7.13:8082/api/auth';

  // --- CAMBIO 1: Configurar el Client ID ---
  // Aunque no uses Firebase, para Windows/Web necesitas pasar el Client ID 
  // que generaste en la Google Cloud Console (Tipo: Aplicación Web).
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '1008130346590-9ilfj26ft3s8n2ki85gf5tmaspehn8mk.apps.googleusercontent.com',
  );

  /// Login tradicional con usuario y contraseña (Este ya lo tienes bien)
  Future<String?> intentarLogin(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signin'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "contrasenya": password}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) return response.body;
      if (response.statusCode == 403) return "CUENTA_NO_VERIFICADA";
      if (response.statusCode == 401) return "CREDENCIALES_MAL";
      return "ERROR_DESCONOCIDO";
    } catch (e) {
      print("Error detallado: $e");
      return "ERROR_CONEXION";
    }
  }

  /// Inicio de sesión con Google mejorado
  Future<String?> iniciarSesionConGoogle() async {
    try {
      // Limpiamos sesión previa para que siempre deje elegir cuenta
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("El usuario canceló el inicio de sesión");
        return null;
      }

      // --- CAMBIO 2: Obtener el ID Token de forma segura ---
      // Esto es lo que Spring Boot verificará para saber que no es un login falso
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken; 

      if (idToken == null) {
        print("No se pudo obtener el ID Token");
        return "ERROR_TOKEN";
      }

      // --- CAMBIO 3: Enviar el ID Token al backend ---
      // Solo enviamos el idToken. Tu Spring Boot (con la librería que pusimos en el pom.xml)
      // se encargará de extraer el email, nombre e imagen desde ese token.
      final response = await http.post(
        Uri.parse('$baseUrl/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "idToken": idToken, 
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Aquí recibes el JwtResponse (Token JWT de tu Spring Boot + datos de tu MySQL)
        return response.body; 
      } else {
        print("Error Servidor: ${response.statusCode} - ${response.body}");
        return "ERROR_SERVIDOR";
      }
    } catch (e) {
      print("Error crítico Google Sign-In: $e");
      return "ERROR_CONEXION";
    }
  }
}