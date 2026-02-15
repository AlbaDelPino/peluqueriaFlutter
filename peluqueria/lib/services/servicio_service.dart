import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/servicios/servicio_model.dart';
import '../../models/servicios/tipo_servicio_model.dart';
import '../../models/horario/horario_model.dart';
import 'user_preferences.dart'; // Tu clase que usa FlutterSecureStorage
import '../../config/api_config.dart';

class ServicioService {
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
        Uri.parse(ApiConfig.serviciosUrl),
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
        Uri.parse(ApiConfig.tiposServicioUrl),
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
    try {
      if (clienteId == 0) return [];

      final headers = await _getAuthHeaders();
      final url = Uri.parse(ApiConfig.favoritosCliente(clienteId));
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // 1. Decodificamos la lista de objetos que viste en Postman
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        // 2. Extraemos SOLO el campo 'id_servicio' de cada objeto para crear la lista de IDs
        return data.map((item) => item['id_servicio'] as int).toList();
      }
      return [];
    } catch (e) {
      print("Error parseando favoritos de la API: $e");
      return [];
    }
  }

  Future<bool> agregarFavorito(int clienteId, int servicioId) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse(ApiConfig.favoritoAccion(clienteId, servicioId));

      final response = await http.post(url, headers: headers);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> eliminarFavorito(int clienteId, int servicioId) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse(ApiConfig.favoritoAccion(clienteId, servicioId));

      final response = await http.delete(url, headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 1. Buscar horarios usando tu endpoint @GetMapping("/buscar")
  Future<List<HorarioSemanal>> buscarHorariosPorDiaYServicio(
    String diaSemana,
    int idServicio,
  ) async {
    try {
      final token = await _prefs.token;
      // Construimos la URL con los QueryParams que pide tu controlador
      final url = Uri.parse(ApiConfig.buscarHorariosUrl).replace(
        queryParameters: {
          'diaSemana': diaSemana.toUpperCase(), // Ej: "LUNES"
          'idServicio': idServicio.toString(),
        },
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
        return body.map((item) => HorarioSemanal.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error en buscarHorarios: $e");
      return [];
    }
  }

  // 2. Crear la reserva (POST)
  // Método corregido en servicio_service.dart
  Future<bool> crearReserva(
    int clienteId,
    int horarioId,
    String fecha,
    String horaInicio,
  ) async {
    try {
      final token = await _prefs.token;
      final url = Uri.parse(ApiConfig.reservarCitaUrl);

      // Creamos el mapa asegurando tipos de datos puros
      final Map<String, dynamic> citaRequest = {
        "fecha": fecha, // String -> "2026-02-16"
        "horaInicio": horaInicio, // String -> "08:50"
        "cliente": {
          "id": clienteId, // int -> 19 (sin comillas en el JSON)
        },
        "horario": {
          "id": horarioId, // int -> 1 (sin comillas en el JSON)
        },
      };

      print("--- INICIANDO PETICIÓN ---");
      print("URL: $url");
      print("JSON a enviar: ${jsonEncode(citaRequest)}");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(citaRequest),
      );

      print("Respuesta del servidor (Status): ${response.statusCode}");

      // Si el código es 403, imprimimos el cuerpo para ver si Spring Security dice algo
      if (response.statusCode == 403) {
        print(
          "ERROR 403: Acceso denegado. Revisa el Token o los permisos en Java.",
        );
        print("Cuerpo del error: ${response.body}");
      }

      // Retornamos true si se creó (201) o si el servidor respondió OK (200)
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("EXCEPCIÓN EN crearReserva: $e");
      return false;
    }
  }

  // En servicio_service.dart
  // En servicio_service.dart

  Future<Map<String, int>> obtenerPlazasDisponibles(
    String fecha,
    int horarioId,
  ) async {
    try {
      final headers = await _getAuthHeaders();
      // URL: /citas/disponible?fecha=2026-01-19&horarioId=1
      final url = Uri.parse(ApiConfig.plazasDisponiblesUrl).replace(
        queryParameters: {'fecha': fecha, 'horarioId': horarioId.toString()},
      );

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Asumiendo que tu API devuelve algo como: {"libres": 3, "totales": 5}
        return {"libres": data['libres'] ?? 0, "totales": data['totales'] ?? 0};
      }
    } catch (e) {
      print("Error consultando plazas: $e");
    }
    return {"libres": 0, "totales": 0};
  }

  Future<List<HorarioSemanal>> buscarHorariosPorServicio(int idServicio) async {
    try {
      // 1. Obtenemos el token guardado para la cabecera
      final token = await _prefs.token;

      // 2. Construimos la URL (Asegúrate que coincida con tu backend de C#)
      // Equivale a: http://localhost:8082/horarios/servicio/{id}
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/horarios/servicio/$idServicio',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Seguridad como en tu C#
        },
      );

      if (response.statusCode == 200) {
        // 3. Decodificamos la lista de horarios
        List<dynamic> body = jsonDecode(response.body);

        // 4. Convertimos cada item del JSON a un objeto HorarioSemanal
        return body.map((item) => HorarioSemanal.fromJson(item)).toList();
      } else {
        print("Error en servidor: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error de conexión en buscarHorariosPorServicio: $e");
      return []; // Devolvemos lista vacía para no romper la app
    }
  }
}
