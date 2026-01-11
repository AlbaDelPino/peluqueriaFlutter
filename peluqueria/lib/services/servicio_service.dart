import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/servicios/servicio_model.dart';
import '../../models/servicios/tipo_servicio_model.dart';
import 'user_preferences.dart'; // Tu clase que usa FlutterSecureStorage

class ServicioService {
  final String _baseUrl = 'http://10.50.183.95:8082';
  final UserPreferences _prefs = UserPreferences();

  // Función privada para no repetir código: obtiene los headers con el Token
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _prefs.token; // Recupera el JWT de Secure Storage
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // La llave para el servidor
    };
  }

  // 1. OBTENER TODOS LOS SERVICIOS
  Future<List<Servicio>> obtenerTodos() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/servicio'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((item) => Servicio.fromJson(item)).toList();
      } else {
        print("Error en obtenerTodos (Auth): ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Excepción conexión servicios: $e");
      return [];
    }
  }

  // 2. OBTENER CATEGORÍAS
  Future<List<TipoServicio>> obtenerTipos() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/tiposervicio'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((item) => TipoServicio.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error en obtenerTipos: $e");
      return [];
    }
  }

  // 3. OBTENER IDS DE FAVORITOS
  Future<List<int>> obtenerIdsFavoritos(int clienteId) async {
    if (clienteId == 0) return [];
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/favoritos/cliente/$clienteId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        // Ajusta 'idServicio' según el nombre que devuelva tu JSON
        return body.map((f) => f['idServicio'] as int).toList();
      }
      return [];
    } catch (e) {
      print("Error en obtenerIdsFavoritos: $e");
      return [];
    }
  }

  // 4. AGREGAR A FAVORITOS
  Future<bool> agregarFavorito(int clienteId, int servicioId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/favoritos'),
        headers: headers,
        body: json.encode({
          "clienteId": clienteId, // Verifica estos nombres con tu Backend
          "servicioId": servicioId,
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 5. ELIMINAR DE FAVORITOS
  Future<bool> eliminarFavorito(int clienteId, int servicioId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/favoritos/$clienteId/$servicioId'),
        headers: headers,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
