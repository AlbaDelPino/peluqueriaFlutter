import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../models/horario/horario_model.dart';
import '../../config/api_config.dart';
import 'user_preferences.dart';

class HorarioService {
  final UserPreferences _prefs = UserPreferences();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _prefs.token;
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  // Obtiene los bloqueos de fecha
  Future<List<DateTime>> obtenerDiasBloqueados() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse(ApiConfig.bloqueosUrl), headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
        return body.map((item) => DateTime.parse(item['fecha'])).toList();
      }
    } catch (e) {
      debugPrint("Error obteniendo bloqueos: $e");
    }
    return [];
  }
  Future<List<Map<String, dynamic>>> obtenerBloqueosCompletos() async {
  try {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse("${ApiConfig.baseUrl}/bloqueos"), headers: headers);
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(body);
    }
  } catch (e) {
    debugPrint("Error en obtenerBloqueos: $e");
  }
  return [];
}

  // Busca qué días de la semana tiene configurados un servicio
  Future<List<HorarioSemanal>> buscarHorariosPorServicio(int idServicio) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('${ApiConfig.baseUrl}/horarios/servicio/$idServicio');
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
        return body.map((item) => HorarioSemanal.fromJson(item)).toList();
      } else {
        debugPrint("Error buscarHorariosPorServicio: Código ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Error buscarHorariosPorServicio: $e");
    }
    return [];
  }

  // Obtiene los turnos para un día y servicio concreto
  Future<List<HorarioSemanal>> buscarHorariosPorDiaYServicio(String dia, int idServicio) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse(ApiConfig.buscarHorariosUrl).replace(queryParameters: {
        'diaSemana': dia.toUpperCase(),
        'idServicio': idServicio.toString(),
      });
      debugPrint("Realizando GET a: $url");
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
        return body.map((item) => HorarioSemanal.fromJson(item)).toList();
      } else {
        debugPrint("Error buscarHorariosPorDiaYServicio: Código ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Error buscarHorariosPorDiaYServicio: $e");
    }
    return [];
  }

  // Consulta plazas libres en un bloque horario
  Future<Map<String, dynamic>> obtenerPlazasDisponibles(String fecha, int horarioId) async {
    final headers = await _getAuthHeaders();
    final url = Uri.parse("${ApiConfig.plazasDisponiblesUrl}?horarioId=$horarioId&fecha=$fecha");
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) return jsonDecode(response.body);
    return {};
  }

  // CREAR RESERVA: Formato JSON con guiones y objetos anidados
  Future<bool> crearReserva(int clienteId, int horarioId, DateTime fechaSel, String horaInicio) async {
    try {
      final headers = await _getAuthHeaders();
      final String fechaISO = DateFormat('yyyy-MM-dd').format(fechaSel);

      final Map<String, dynamic> requestBody = {
        "fecha": fechaISO,
        "horaInicio": horaInicio,
        "cliente": {"id": clienteId},
        "horario": {"id": horarioId}
      };

      final response = await http.post(
        Uri.parse(ApiConfig.reservarCitaUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Error en reserva: $e");
      return false;
    }
  }
}