import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserPreferences {
  static final UserPreferences _instancia = UserPreferences._internal();
  factory UserPreferences() => _instancia;
  UserPreferences._internal();

  late SharedPreferences _prefs;

  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 1. GUARDAR TODO AL INICIAR SESIÓN
  // Dentro de UserPreferences.dart
  Future<void> guardarSesion(
    String jsonResponse,
    String passwordEscrita,
  ) async {
    try {
      // Intentamos decodificar
      final Map<String, dynamic> decodedData = json.decode(jsonResponse);

      await _prefs.setString('token_jwt', decodedData['token'] ?? '');
      await _prefs.setString('user_password', passwordEscrita);
      await _prefs.setInt('user_id', decodedData['id'] ?? 0);
      await _prefs.setString('nombre_usuario', decodedData['nombre'] ?? '');
      await _prefs.setString('username', decodedData['username'] ?? '');
      await _prefs.setString('user_email', decodedData['email'] ?? '');
      await _prefs.setString('user_imagen', decodedData['imagen'] ?? '');
      await _prefs.setString(
        'user_telefono',
        decodedData['telefono']?.toString() ?? '',
      );
      await _prefs.setString('user_direccion', decodedData['direccion'] ?? '');
      await _prefs.setString('user_alergenos', decodedData['alergenos'] ?? '');
      await _prefs.setInt('fecha_login', DateTime.now().millisecondsSinceEpoch);
      await _prefs.setBool('estaLogueado', true);
    } catch (e) {
      // Si algo falla aquí, imprimimos pero no rompemos la app
      print("Error crítico en guardarSesion: $e");
    }
  }

  // 2. ACTUALIZAR PERFIL (Cuando el usuario edita sus datos)
  Future<void> actualizarPerfilLocal({
    required String nombre,
    required String imagen,
    String? email,
    String? telefono,
    String? direccion,
  }) async {
    await _prefs.setString('nombre_usuario', nombre);
    await _prefs.setString('user_imagen', imagen);
    if (email != null) await _prefs.setString('user_email', email);
    if (telefono != null) await _prefs.setString('user_telefono', telefono);
    if (direccion != null) await _prefs.setString('user_direccion', direccion);
  }

  // 3. GETTERS (Para leer los datos desde cualquier pantalla)
  String get token => _prefs.getString('token_jwt') ?? '';
  String get passwordSegura => _prefs.getString('user_password') ?? '';
  String get nombreUsuario => _prefs.getString('nombre_usuario') ?? 'Usuario';
  String get imagenUsuario => _prefs.getString('user_imagen') ?? '';
  String get emailUsuario => _prefs.getString('user_email') ?? '';
  // Añade estos a tu lista de getters existentes
  int get userId => _prefs.getInt('user_id') ?? 0;
  String get username => _prefs.getString('username') ?? '';
  String get telefonoUsuario => _prefs.getString('user_telefono') ?? '';
  String get direccionUsuario => _prefs.getString('user_direccion') ?? '';
  String get alergenosUsuario => _prefs.getString('user_alergenos') ?? '';

  bool get esSesionValida {
    final int fechaLogin = _prefs.getInt('fecha_login') ?? 0;
    if (fechaLogin == 0) return false;
    final int diferenciaHoras = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(fechaLogin))
        .inHours;
    return diferenciaHoras < 24;
  }

  Future<void> logout() async {
    await _prefs.clear();
  }
}
