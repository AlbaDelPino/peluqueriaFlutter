import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/api_config.dart';


class UserPreferences {
  static final UserPreferences _instancia = UserPreferences._internal();
  factory UserPreferences() => _instancia;
  UserPreferences._internal();

  final _storage = const FlutterSecureStorage();

  // --- GUARDAR SESIÓN ---
  Future<void> guardarSesion(
    String jsonResponse,
    String passwordEscrita,
  ) async {
    try {
      final Map<String, dynamic> decodedData = json.decode(jsonResponse);

      await _storage.write(key: 'token_jwt', value: decodedData['token'] ?? '');
      await _storage.write(
        key: 'user_id',
        value: (decodedData['id'] ?? 0).toString(),
      );
      await _storage.write(key: 'user_password', value: passwordEscrita);
      await _storage.write(
        key: 'nombre_usuario',
        value: decodedData['nombre'] ?? '',
      );
      await _storage.write(
        key: 'username',
        value: decodedData['username'] ?? '',
      );
      await _storage.write(
        key: 'user_email',
        value: decodedData['email'] ?? '',
      );
      await _storage.write(
        key: 'user_imagen',
        value: decodedData['imagen'] ?? '',
      );
      await _storage.write(
        key: 'user_telefono',
        value: decodedData['telefono']?.toString() ?? '',
      );
      
      await _storage.write(key: 'estaLogueado', value: 'true');
    } catch (e) {
      print("Error en guardarSesion: $e");
    }
  }

  // --- GETTERS ASÍNCRONOS ---
  Future<String> get token async => await _storage.read(key: 'token_jwt') ?? '';
  Future<String> get passwordSegura async =>
      await _storage.read(key: 'user_password') ?? '';
  Future<int> get userId async {
    String? id = await _storage.read(key: 'user_id');
    return int.tryParse(id ?? '0') ?? 0;
  }

  Future<String> get nombreUsuario async =>
      await _storage.read(key: 'nombre_usuario') ?? '';
  Future<String> get imagenUsuario async =>
      await _storage.read(key: 'user_imagen') ?? '';

  // --- ACTUALIZAR PERFIL ---
  Future<void> actualizarPerfilLocal({
    required String nombre,
    required String imagen,
    String? email,
    String? telefono,
  }) async {
    await _storage.write(key: 'nombre_usuario', value: nombre);
    await _storage.write(key: 'user_imagen', value: imagen);
    if (email != null) await _storage.write(key: 'user_email', value: email);
    if (telefono != null)
      await _storage.write(key: 'user_telefono', value: telefono);
   
  }

  // --- VALIDACIÓN ---
  Future<bool> verificarTokenEnServidor() async {
    final String currentToken = await token;
    if (currentToken.isEmpty) return false;

    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.meUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $currentToken',
            },
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    await _storage.deleteAll();
  }
}
