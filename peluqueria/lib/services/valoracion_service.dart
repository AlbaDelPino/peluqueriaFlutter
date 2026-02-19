import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/valoracion/valoracion_model.dart';

class ValoracionService {
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- CREAR VALORACIÓN (POST) ---
  Future<bool> crearValoracion(Valoracion valoracion, int idCliente, int idCita) async {
    
    // Solo dejamos la validación crítica (la puntuación)
    if (valoracion.puntuacion == 0) {
      debugPrint("Validación rechazada: Puntuación 0");
      return false; 
    }

    // Eliminamos la validación del comentario aquí para que sea opcional 
    // tal como pusiste en el TextField ("opcional")

    final url = Uri.parse(ApiConfig.postValoracion(idCliente));
    final token = await _getToken();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // Usamos la configuración de APIs de 'config api+'
        body: jsonEncode(valoracion.toJson(idCita)),
      );

      debugPrint("Respuesta Servidor: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Error POST Valoración: $e");
      return false;
    }
  }

  // --- OBTENER VALORACIÓN DE UNA CITA ---
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
        
        // Buscamos si entre todas las valoraciones del cliente existe la de esta cita
        final jsonValoracion = lista.firstWhere(
          (v) => v['cita'] != null && v['cita']['id'] == idCita,
          orElse: () => null,
        );
        
        return jsonValoracion != null ? Valoracion.fromJson(jsonValoracion) : null;
      }
    } catch (e) {
      debugPrint("Error GET Valoración: $e");
    }
    return null;
  }
}