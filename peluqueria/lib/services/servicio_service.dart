import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/servicios/servicio_model.dart';
import '../models/servicios/tipo_servicio_model.dart';

class ServicioService {
  // Asegúrate de que los puertos y rutas coincidan con tu backend
  final String urlServicios = "http://10.103.246.95:8082/servicio";
  final String urlTipos = "http://10.103.246.95:8082/tiposervicio";

  // Función genérica para obtener el Token y ahorrar código
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token_jwt');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

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
}
