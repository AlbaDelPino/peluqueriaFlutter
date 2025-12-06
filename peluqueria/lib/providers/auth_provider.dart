import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../shared_prefs/user_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _loading = false;
  String? _token;
  String? _username;
  String? _email;
  int? _clienteId;

  bool get loading => _loading;
  String? get token => _token;
  String? get username => _username;
  String? get email => _email;
  int? get clienteId => _clienteId;
  bool get isAuthenticated => _token != null;

  /// LOGIN
  Future<bool> login({required String username, required String password}) async {
  _loading = true;
  notifyListeners();

  final url = Uri.parse(
      'http://localhost:8082/api/auth/signin');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": username,
        "contrasenya": password, 
      }),
    );

    _loading = false;

      //si al respuesta es correcta , converte el body en mapa Json
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      _token = data['token'];
      _username = data['username'];
      _email = data['email'];
      _clienteId = data['id'];

      if (_token == null || _username == null || _clienteId == null) {
        debugPrint("Login JSON incompleto: $data");
        return false;
      }
//Persiste los datos en SharedPreferences.
      final prefs = UserPreferences();
      prefs.token = _token!;
      prefs.username = _username!;
      prefs.email = _email ?? '';
      prefs.clienteId = _clienteId!;

      notifyListeners();
      return true;
    } else {
      final errorMsg = jsonDecode(response.body)['message'] ?? 'Error desconocido';
      debugPrint("Error login: $errorMsg");
      notifyListeners();
      return false;
    }
  } catch (e) {
    _loading = false;
    debugPrint("Excepción login: $e");
    notifyListeners();
    return false;
  }
}


  /// SIGNUP
  Future<bool> signup({
    required String username,
    required String nombre,
    required String email,
    required String telefono,
    required String password,
    required String alergenos,
    required String direccion,
    required String observacion,
  }) async {
    _loading = true;
    notifyListeners();

    final url = Uri.parse(
        'http://localhost:8082/api/auth/signup/cliente/public');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": username,
        "nombre": nombre,
        "email": email,
        "telefono": telefono,
        "contrasenya": password,
        "estado": true,
        "role": "ROLE_CLIENTE",
        "alergenos": alergenos,
        "direccion": direccion,
        "observacion": observacion,
      }),
    );

    _loading = false;

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      debugPrint("Signup response: $data");

      if (data['token'] != null) {
        _token = data['token'];
        _username = data['username'];
        _email = data['email'];
        _clienteId = data['id'];

        final prefs = UserPreferences();
        prefs.token = _token!;
        prefs.username = _username!;
        prefs.email = _email ?? '';
        if (_clienteId != null) prefs.clienteId = _clienteId!;
      }

      notifyListeners();
      return true;
    } else {
      debugPrint("Error signup: ${response.statusCode} - ${response.body}");
      notifyListeners();
      return false;
    }
  }

  /// LOGOUT
  void logout() {
    _token = null;
    _username = null;
    _email = null;
    _clienteId = null;

    final prefs = UserPreferences();
    prefs.clear();

    _loading = false;
    notifyListeners();
  }
}
