import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/user_preferences.dart'; // Usamos tu clase de preferencias

class CambiarPasswordScreen extends StatefulWidget {
  const CambiarPasswordScreen({super.key});

  @override
  State<CambiarPasswordScreen> createState() => _CambiarPasswordScreenState();
}

class _CambiarPasswordScreenState extends State<CambiarPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passNuevaCtrl = TextEditingController();
  final _passConfirmaCtrl = TextEditingController();

  bool _isLoading = false;
  final Color naranjaLogo = const Color(0xFFFF6B00);

  @override
  void dispose() {
    _passNuevaCtrl.dispose();
    _passConfirmaCtrl.dispose();
    super.dispose();
  }

  Future<void> _actualizarPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passNuevaCtrl.text != _passConfirmaCtrl.text) {
      _mostrarMensaje("Las contraseñas no coinciden", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = UserPreferences();
      // Usamos el ID guardado en tus preferencias (ajusta el nombre si es diferente en tu UserPreferences)
      // Si no tienes el ID en UserPreferences, asegúrate de añadirlo.
      final int idCliente = prefs.userId;
      final String token = prefs.token;

      // 1. OBTENER DATOS ACTUALES DEL CLIENTE (Para no enviar nulls)
      final getResponse = await http.get(
        Uri.parse('http://10.103.246.95:8082/api/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (getResponse.statusCode != 200) {
        _mostrarMensaje("Error al obtener datos del servidor", isError: true);
        return;
      }

      final Map<String, dynamic> clienteActual = jsonDecode(getResponse.body);

      // 2. PREPARAR EL OBJETO COMPLETO CON LA NUEVA CONTRASEÑA
      clienteActual['contrasenya'] = _passNuevaCtrl.text.trim();

      // 3. ENVIAR EL PUT AL BACKEND
      final response = await http.put(
        Uri.parse('http://10.103.246.95:8082/clientes/$idCliente'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(clienteActual),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _mostrarMensaje("✅ Contraseña actualizada correctamente");
        if (mounted) Navigator.pop(context);
      } else {
        debugPrint("Error Body: ${response.body}");
        _mostrarMensaje(
          "El servidor rechazó el cambio (${response.statusCode})",
          isError: true,
        );
      }
    } catch (e) {
      debugPrint("Error Catch: $e");
      _mostrarMensaje("Error de conexión", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarMensaje(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "SEGURIDAD",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: naranjaLogo,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(
                Icons.lock_reset_rounded,
                size: 80,
                color: Color(0xFFFF6B00),
              ),
              const SizedBox(height: 20),
              const Text(
                "Nueva Contraseña",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              _buildField(
                _passNuevaCtrl,
                "Escribe la nueva contraseña",
                Icons.lock_outline,
              ),
              const SizedBox(height: 20),
              _buildField(
                _passConfirmaCtrl,
                "Confirma la contraseña",
                Icons.lock_reset_outlined,
              ),

              const SizedBox(height: 40),

              _isLoading
                  ? CircularProgressIndicator(color: naranjaLogo)
                  : ElevatedButton(
                      onPressed: _actualizarPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: naranjaLogo,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "ACTUALIZAR AHORA",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: naranjaLogo),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (v) =>
          (v == null || v.length < 6) ? "Mínimo 6 caracteres" : null,
    );
  }
}
