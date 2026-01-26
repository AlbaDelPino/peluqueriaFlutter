import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/user_preferences.dart';

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

      // 🔥 CORRECCIÓN: Ahora usamos await para obtener los datos de Secure Storage
      final int idCliente = await prefs.userId;
      final String tokenActual = await prefs.token;

      if (tokenActual.isEmpty || idCliente == 0) {
        _mostrarMensaje("Sesión no válida", isError: true);
        return;
      }

      // 1. OBTENER DATOS ACTUALES DEL CLIENTE
      // Usamos la IP de tu servidor para evitar problemas con localhost
      final getResponse = await http.get(
        Uri.parse('http://192.168.7.13:8082/api/auth/me'),
        headers: {'Authorization': 'Bearer $tokenActual'},
      );

      if (getResponse.statusCode != 200) {
        _mostrarMensaje("Error al obtener datos del servidor", isError: true);
        return;
      }

      final Map<String, dynamic> clienteActual = jsonDecode(getResponse.body);

      // 2. ACTUALIZAR LA CONTRASEÑA EN EL OBJETO
      final String nuevaPass = _passNuevaCtrl.text.trim();
      clienteActual['contrasenya'] = nuevaPass;

      // 3. ENVIAR EL PUT AL BACKEND
      final response = await http.put(
        Uri.parse('http://192.168.7.13:8082/clientes/$idCliente'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tokenActual',
        },
        body: jsonEncode(clienteActual),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 🔥 IMPORTANTE: Actualizamos también la contraseña guardada localmente
        // para que las futuras peticiones PUT (como en editar perfil) no fallen.
        // Debes asegurarte de tener un método para esto o guardarlo directamente
        // En este caso, simplemente notificamos el éxito.

        _mostrarMensaje("✅ Contraseña actualizada correctamente");
        if (mounted) Navigator.pop(context);
      } else {
        _mostrarMensaje(
          "El servidor rechazó el cambio (${response.statusCode})",
          isError: true,
        );
      }
    } catch (e) {
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
