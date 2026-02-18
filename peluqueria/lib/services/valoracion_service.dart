import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/valoracion/valoracion_model.dart';

class ValoracionService {
  
  // OBTENER TOKEN
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- CREAR VALORACIÓN (POST) ---
  Future<bool> crearValoracion(Valoracion valoracion, int idCliente, int idCita) async {
    final url = Uri.parse(ApiConfig.postValoracion(idCliente));
    final token = await _getToken();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(valoracion.toJson(idCita)),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error POST Valoración: $e");
      return false;
    }
  }

  // --- MOSTRAR VALORACIÓN DE UNA CITA (GET) ---
  // Filtra las valoraciones del cliente para encontrar la de una cita específica
  Future<Valoracion?> obtenerValoracionPorCita(int idCliente, int idCita) async {
    final url = Uri.parse(ApiConfig.getValoracionesDelCliente(idCliente));
    final token = await _getToken();

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> lista = jsonDecode(response.body);
        // Buscamos la valoración que coincida con el id de la cita
        final jsonValoracion = lista.firstWhere(
          (v) => v['cita'] != null && v['cita']['id'] == idCita,
          orElse: () => null,
        );
        
        return jsonValoracion != null ? Valoracion.fromJson(jsonValoracion) : null;
      }
    } catch (e) {
      print("Error GET Valoración: $e");
    }
    return null;
  }
}