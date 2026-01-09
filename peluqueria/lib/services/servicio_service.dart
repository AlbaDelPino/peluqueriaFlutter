import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/servicios/servicio_model.dart';
import '../models/servicios/tipo_servicio_model.dart';

class ServicioService {
  // Configuración de URLs basada en tu IP de backend
  final String urlServicios = "http://localhost:8082/servicio";
  final String urlTipos = "http://localhost:8082/tiposervicio";
  final String urlFavoritos = "http://localhost:8082/api/favoritos";

  // Función privada para obtener el Token y configurar las cabeceras
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token_jwt');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- MÉTODOS DE SERVICIOS ---

  Future<List<Servicio>> obtenerTodos() async {
    try {
      final response = await http.get(
        Uri.parse(urlServicios),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Servicio.fromJson(item)).toList();
      } else {
        throw Exception('Error al cargar servicios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión en servicios: $e');
    }
  }

  Future<List<TipoServicio>> obtenerTipos() async {
    try {
      final response = await http.get(
        Uri.parse(urlTipos),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => TipoServicio.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar tipos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión en tipos: $e');
    }
  }

  // --- MÉTODOS DE FAVORITOS ---

  /// Obtiene la lista de IDs de servicios que el cliente tiene como favoritos
  Future<List<int>> obtenerIdsFavoritos(int clienteId) async {
    try {
      final response = await http.get(
        Uri.parse("$urlFavoritos/cliente/$clienteId"),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        // Mapeamos el JSON para obtener solo el id_servicio de cada objeto Servicio
        return body.map((item) => item['id_servicio'] as int).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error obteniendo favoritos: $e");
      return [];
    }
  }

  /// Agrega un servicio a la tabla de favoritos del cliente
  Future<bool> agregarFavorito(int clienteId, int servicioId) async {
    try {
      final response = await http.post(
        Uri.parse("$urlFavoritos/cliente/$clienteId/servicio/$servicioId"),
        headers: await _getHeaders(),
      );
      // Retornamos true si el backend responde con éxito (200 o 201 Created)
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error al agregar favorito: $e");
      return false;
    }
  }

  /// Elimina un servicio de la tabla de favoritos del cliente
  Future<bool> eliminarFavorito(int clienteId, int servicioId) async {
    try {
      final response = await http.delete(
        Uri.parse("$urlFavoritos/cliente/$clienteId/servicio/$servicioId"),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error al eliminar favorito: $e");
      return false;
    }
  }
}