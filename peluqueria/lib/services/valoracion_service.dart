import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ValoracionService {
  Future<bool> enviarValoracion({
    required int idCliente,
    required int idCita,
    required String comentario,
    required int puntuacion,
    File? imagen,
  }) async {
    final url = Uri.parse(ApiConfig.crearValoracionUrl(idCliente));
    
    // Obtenemos el token para la seguridad
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Convertir imagen a Base64 si existe
    String? base64Image;
    if (imagen != null) {
      List<int> imageBytes = await imagen.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }

    // Construir el body según tu entidad Java
    final Map<String, dynamic> body = {
      "comentario": comentario,
      "puntuacion": puntuacion,
      "trato": puntuacion, // Tu backend pide trato, desarrollo, etc. 
      "desarrollo": puntuacion, // Por ahora enviamos la misma nota a todos
      "comunicacion": puntuacion,
      "organizacion": puntuacion,
      "imagen": base64Image,
      "cita": {"id": idCita}
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error en ValoracionService: $e");
      return false;
    }
  }
}