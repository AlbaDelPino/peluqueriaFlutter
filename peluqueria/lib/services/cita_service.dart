import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'user_preferences.dart';


class CitaService {
  final UserPreferences _prefs = UserPreferences();

  // Obtener historial de citas
  Future<List<dynamic>> obtenerCitasPorCliente() async {
    final int id = await _prefs.userId;
    final String token = await _prefs.token;

    final response = await http.get(
      Uri.parse(ApiConfig.getCitasByCliente(id)),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception("Error al obtener citas");
  }

  // Reservar una nueva cita
  Future<bool> reservarCita(Map<String, dynamic> citaData) async {
    final String token = await _prefs.token;

    final response = await http.post(
      Uri.parse(ApiConfig.reservarCitaUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(citaData),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}