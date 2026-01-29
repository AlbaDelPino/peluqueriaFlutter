import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import '../config/api_config.dart';
import 'user_preferences.dart'; // Tu clase que usa FlutterSecureStorage
import '../models/usuario/cliente_model.dart'; 

class AuthService {
  final UserPreferences _prefs = UserPreferences();

  // --- CAMBIO 1: Configurar el Client ID ---
  // Aunque no uses Firebase, para Windows/Web necesitas pasar el Client ID 
  // que generaste en la Google Cloud Console (Tipo: Aplicación Web).
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '1008130346590-9ilfj26ft3s8n2ki85gf5tmaspehn8mk.apps.googleusercontent.com',
  );

  /// Login tradicional con usuario y contraseña (Este ya lo tienes bien)
  Future<String?> intentarLogin(String username, String password) async {
  try {
    print("Intentando login en: ${ApiConfig.loginUrl}"); // Ver si la URL es correcta
    print("Datos enviados: username: $username, password: $password");

    final response = await http.post(
      Uri.parse(ApiConfig.loginUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "contrasenya": password}),
    ).timeout(const Duration(seconds: 10));

    // ESTO ES LO MÁS IMPORTANTE:
    print("CÓDIGO RECIBIDO: ${response.statusCode}"); 
    print("CUERPO RECIBIDO: ${response.body}");

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
        Uri.parse(ApiConfig.googleLoginUrl),
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

  Future<http.Response> register(Map<String, dynamic> userData) async {
    final url = Uri.parse(ApiConfig.signupUrl);
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
  }
Future<http.Response> sendForgotPasswordEmail(String email) async {
  // Construimos la URL manualmente para asegurar que no hay barras extra
  // Java espera: http://192.168.7.13:8082/api/auth/forgot-password?email=correo@test.com
  final String urlString = "${ApiConfig.baseUrl}/api/auth/forgot-password?email=$email";
  final url = Uri.parse(urlString);
  
  print("-----------------------------------------");
  print("🚀 ENVIANDO PETICIÓN A: $urlString");
  print("-----------------------------------------");

  try {
    // Usamos POST tal cual lo tienes en el Controller de Java
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    print("📥 RESPUESTA SERVIDOR: ${response.statusCode}");
    print("📝 CUERPO RECIBIDO: ${response.body}");
    
    return response;
  } catch (e) {
    print("❌ ERROR DE CONEXIÓN: $e");
    rethrow;
  }
}

  // En services/auth_service.dart
Future<http.Response> resetPassword(String email, String codigo, String nuevaPassword) async {
  final url = Uri.parse(ApiConfig.resetPasswordUrl);
  return await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "email": email,
      "codigo": codigo,
      "nuevaPassword": nuevaPassword,
    }),
  );
}

// Añade esto a tu clase AuthService
Future<bool> updateInternalPassword(String nuevaPassword) async {
  final UserPreferences prefs = UserPreferences();
  final String token = await prefs.token;
  final int id = await prefs.userId;

  try {
    // 1. Obtener datos actuales
    final getResp = await http.get(
      Uri.parse(ApiConfig.meUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (getResp.statusCode != 200) return false;

    final Map<String, dynamic> cliente = jsonDecode(getResp.statusCode == 200 ? getResp.body : "");
    cliente['contrasenya'] = nuevaPassword;

    // 2. Enviar actualización
    final putResp = await http.put(
      Uri.parse(ApiConfig.clientesUrl(id)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(cliente),
    );

    return putResp.statusCode == 200 || putResp.statusCode == 201;
  } catch (e) {
    return false;
  }
}

Future<ClienteModel?> getProfile() async {
    // Ahora _prefs ya existe
    final String token = await _prefs.token; 
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.meUrl),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return ClienteModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      // Importante: Asegúrate de importar 'package:flutter/foundation.dart' para usar debugPrint

    }
    return null;
  }

Future<bool> updateProfile(Map<String, dynamic> userData) async {
  final String token = await _prefs.token;
  final int id = await _prefs.userId;
  try {
    String cuerpoJson = jsonEncode(userData);

    print("🚀 ENVIANDO PUT A: ${ApiConfig.clientesUrl(id)}");
    print("🔑 TOKEN: Bearer $token");
    print("📦 JSON BODY: $cuerpoJson");

    final response = await http.put(
      Uri.parse(ApiConfig.clientesUrl(id)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(userData),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    return false;
  }


}
}
