import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/user_preferences.dart';
import '../../config/api_config.dart';
import '../../services/auth_service.dart';
import 'package:peluqueria/widget/texto_automatico.dart';

class CambiarPasswordScreen extends StatefulWidget {
  const CambiarPasswordScreen({super.key});

  @override
  State<CambiarPasswordScreen> createState() => _CambiarPasswordScreenState();
}

class _CambiarPasswordScreenState extends State<CambiarPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passNuevaCtrl = TextEditingController();
  final _passConfirmaCtrl = TextEditingController();
final AuthService _authService = AuthService();
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
      // Llamada limpia al servicio
      final exitoso = await _authService.updateInternalPassword(_passNuevaCtrl.text.trim());

      if (exitoso) {
        _mostrarMensaje("✅ Contraseña actualizada correctamente");
        if (mounted) Navigator.pop(context);
      } else {
        _mostrarMensaje("Error al actualizar. Revisa tu sesión.", isError: true);
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
        content: TextoAutomatico(msg),
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
        title: const TextoAutomatico(
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
              const TextoAutomatico(
                "Nueva Contraseña",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              _buildField(
                _passNuevaCtrl,
                TextoAutomatico("Escribe la nueva contraseña"),
            
                Icons.lock_outline,
              ),
              const SizedBox(height: 20),
              _buildField(
                _passConfirmaCtrl,
                const TextoAutomatico("Confirma la contraseña"),
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
                      child: const TextoAutomatico(
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

  Widget _buildField(TextEditingController ctrl, Widget labelWidget, IconData icon) {
    return TextFormField(
      controller: ctrl,
      obscureText: true,
      decoration: InputDecoration(
        label: labelWidget,
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
