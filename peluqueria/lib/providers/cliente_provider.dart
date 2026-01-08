import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/cliente_model.dart';
import '../shared_prefs/user_preferences.dart';

class ClienteProvider with ChangeNotifier {
  Cliente? _cliente;
  Cliente? get cliente => _cliente;

<<<<<<< Updated upstream
<<<<<<< Updated upstream
  /// Cargar cliente desde el backend usando el username
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
  Future<void> cargarClientePorUsername(String username) async {
    try {
      final prefs = UserPreferences();
      final token = prefs.token;

      final url = Uri.parse(
<<<<<<< Updated upstream
<<<<<<< Updated upstream
        //"http://localhost:8082/clientes/username/$username");
        "https://uninquisitorial-weariful-brayan.ngrok-free.dev/clientes/username/$username");
=======
        "https://localhost:8082/clientes/username/$username",
      );
>>>>>>> Stashed changes
=======
        "https://localhost:8082/clientes/username/$username",
      );
>>>>>>> Stashed changes

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cliente = Cliente.fromJson(data);
<<<<<<< Updated upstream
<<<<<<< Updated upstream
        prefs.clienteId = _cliente!.id; // guardamos el id en preferencias
      } else {
        _cliente = null;
        debugPrint("❌ Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      _cliente = null;
      debugPrint("❌ Error cargando cliente: $e");
=======
=======
>>>>>>> Stashed changes

        prefs.clienteId = _cliente!.id; // 👈 guardamos id
      } else {
        _cliente = null;
        debugPrint("Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      _cliente = null;
      debugPrint("Error cargando cliente: $e");
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
    }
    notifyListeners();
  }

<<<<<<< Updated upstream
<<<<<<< Updated upstream
  /// Actualizar cliente en el backend
  Future<void> actualizarCliente(Map<String, dynamic> clienteActualizado) async {
    final prefs = UserPreferences();
    final id = prefs.clienteId;

    if (id == 0) {
      throw Exception("No se encontró el id del cliente en UserPreferences");
    }

    final url = Uri.parse(
      //'http://localhost:8082/clientes/$id');
      'https://uninquisitorial-weariful-brayan.ngrok-free.dev/clientes/$id');

    // Si la contraseña está vacía, no la enviamos
    if (clienteActualizado["contrasenya"] == null ||
        (clienteActualizado["contrasenya"] as String).isEmpty) {
      clienteActualizado.remove("contrasenya");
    }

    debugPrint("➡️ Body enviado: ${json.encode(clienteActualizado)}");

    final resp = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (prefs.token.isNotEmpty) 'Authorization': 'Bearer ${prefs.token}',
      },
      body: json.encode(clienteActualizado),
    );

    if (resp.statusCode == 200) {
      _cliente = Cliente.fromJson(json.decode(resp.body));
      notifyListeners();
    } else {
      debugPrint("❌ Error al actualizar cliente: ${resp.body}");
      throw Exception('Error al actualizar cliente: ${resp.body}');
    }
  }
}
=======
=======
>>>>>>> Stashed changes
  Future<void> actualizarCliente(Map<String, dynamic> clienteActualizado) async {
  final prefs = UserPreferences();
  final id = prefs.clienteId;

  if (id == 0) {
    throw Exception("No se encontró el id del cliente en UserPreferences");
  }

  final url = Uri.parse(
    'https://localhost:8082/clientes/$id',
  );

  // 👇 quitamos contrasenya si está vacía o nula
  if (clienteActualizado["contrasenya"] == null ||
      (clienteActualizado["contrasenya"] as String).isEmpty) {
    clienteActualizado.remove("contrasenya");
  }

  debugPrint("➡️ URL usada para PUT: $url");
  debugPrint("➡️ Token: ${prefs.token}");
  debugPrint("➡️ Body enviado: ${json.encode(clienteActualizado)}");

  final resp = await http.put(
    url,
    headers: {
      'Content-Type': 'application/json',
      if (prefs.token.isNotEmpty) 'Authorization': 'Bearer ${prefs.token}',
    },
    body: json.encode(clienteActualizado),
  );

  if (resp.statusCode == 200) {
    _cliente = Cliente.fromJson(json.decode(resp.body));
    notifyListeners();
  } else {
    debugPrint("❌ Error al actualizar cliente");
    debugPrint("Status: ${resp.statusCode}");
    debugPrint("Body: ${resp.body}");
    throw Exception('Error al actualizar cliente: ${resp.body}');
  }
}

}
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
