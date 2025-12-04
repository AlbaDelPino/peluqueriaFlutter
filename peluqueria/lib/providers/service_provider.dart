import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';
import '../shared_prefs/user_preferences.dart';

class ServiceProvider with ChangeNotifier {
  List<Servicio> _servicios = [];
  List<TipoServicio> _tiposServicio = [];

  List<Servicio> get servicios => _servicios;
  List<TipoServicio> get tiposServicio => _tiposServicio;
// config.dart

  Future<void> cargarServicios() async {
    final prefs = UserPreferences();
    final token = prefs.token;
// config.dart

    final url = Uri.parse('https://localhost:8082/servicio');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _servicios = data.map((e) => Servicio.fromJson(e)).toList();
      notifyListeners();
    } else {
      throw Exception('Error al cargar servicios');
    }
  }

  Future<void> cargarTiposServicio() async {
    final prefs = UserPreferences();
    final token = prefs.token;
// config.dart


    final url = Uri.parse('https://localhost:8082/tiposervicio');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _tiposServicio = data.map((e) => TipoServicio.fromJson(e)).toList();
      notifyListeners();
    } else {
      throw Exception('Error al cargar tipos de servicio');
    }
  }

  List<Servicio> buscarServicios(String query) {
    return _servicios
        .where((s) => s.nombre.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
