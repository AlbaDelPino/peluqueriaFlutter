import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/servicios/servicio_model.dart';
import '../../models/servicios/tipo_servicio_model.dart';
import '../../config/api_config.dart';
import 'user_preferences.dart';

class ServicioService {
  final UserPreferences _prefs = UserPreferences();

  // Función privada para obtener los headers con el Token JWT
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _prefs.token;
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  // --- 1. GESTIÓN DE SERVICIOS ---

  /// Obtiene la lista completa de servicios disponibles en la peluquería
  Future<List<Servicio>> obtenerTodos() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.serviciosUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Usamos utf8.decode para evitar problemas con acentos o caracteres especiales
        List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
        return body.map((item) => Servicio.fromJson(item)).toList();
      } else {
        print("Error al obtener servicios: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Excepción en obtenerTodos: $e");
      return [];
    }
  }

  /// Obtiene las categorías de servicios (Corte, Barba, Tintes, etc.)
  Future<List<TipoServicio>> obtenerTipos() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.tiposServicioUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
        return body.map((item) => TipoServicio.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error en obtenerTipos: $e");
      return [];
    }
  }

  // --- 2. GESTIÓN DE FAVORITOS ---

  /// Obtiene una lista de IDs de los servicios marcados como favoritos por el cliente
  Future<List<int>> obtenerIdsFavoritos(int clienteId) async {
    try {
      if (clienteId == 0) return [];

      final headers = await _getAuthHeaders();
      final url = Uri.parse(ApiConfig.favoritosCliente(clienteId));
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        // Mapeamos los objetos recibidos para extraer solo el id_servicio
        return data.map((item) => item['id_servicio'] as int).toList();
      }
      return [];
    } catch (e) {
      print("Error parseando favoritos: $e");
      return [];
    }
  }

  /// Agrega un servicio a la lista de favoritos del cliente
  Future<bool> agregarFavorito(int clienteId, int servicioId) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse(ApiConfig.favoritoAccion(clienteId, servicioId));

      final response = await http.post(url, headers: headers);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error al agregar favorito: $e");
      return false;
    }
  }

  /// Elimina un servicio de la lista de favoritos del cliente
  Future<bool> eliminarFavorito(int clienteId, int servicioId) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse(ApiConfig.favoritoAccion(clienteId, servicioId));

      final response = await http.delete(url, headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      print("Error al eliminar favorito: $e");
      return false;
    }
  }
}