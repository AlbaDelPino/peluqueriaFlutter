import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para FilteringTextInputFormatter
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../services/auth_service.dart';
import 'package:peluqueria/widget/texto_automatico.dart';


class RestablecerPasswordScreen extends StatefulWidget {
  final String email;
  const RestablecerPasswordScreen({super.key, required this.email});

  @override
  State<RestablecerPasswordScreen> createState() =>
      _RestablecerPasswordScreenState();
}

class _RestablecerPasswordScreenState extends State<RestablecerPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codigoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Paleta de colores BERNAT
  final Color naranjaLogo = const Color(0xFFFF6B00);
  final Color negroSuave = const Color(0xFF2D2D2D);

  Future<void> _actualizarPassword() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final response = await _authService.resetPassword(
        widget.email,
        _codigoCtrl.text.trim(),
        _passCtrl.text.trim(),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          _mostrarMensaje(
            "¡Contraseña actualizada! Ya puedes iniciar sesión.",
            Colors.green,
          );
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        _mostrarMensaje("Código incorrecto o expirado.", Colors.redAccent);
      }
    } catch (e) {
      _mostrarMensaje("Error de conexión.", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarMensaje(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TextoAutomatico(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: negroSuave, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextoAutomatico(
          "NUEVA CONTRASEÑA",
          style: TextStyle(
            color: negroSuave,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Icon(Icons.lock_reset_rounded, size: 80, color: naranjaLogo),
              const SizedBox(height: 20),
              TextoAutomatico(
                "Introduce el código enviado a\n${widget.email}",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 40),

              // CAMPO CÓDIGO (Solo números, Máximo 6)
              _buildModernInput(
                controller: _codigoCtrl,
                label: "CÓDIGO DE 6 DÍGITOS",
                icon: Icons.pin_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: (v) => (v == null || v.length != 6)
                    ? "El código debe tener 6 dígitos"
                    : null,
              ),

              const SizedBox(height: 20),

              // CAMPO CONTRASEÑA (Estilo Login)
              _buildPasswordInput(),

              const SizedBox(height: 40),

              _isLoading
                  ? CircularProgressIndicator(color: naranjaLogo)
                  : _buildBotonRestablecer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: Icon(icon, color: naranjaLogo, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: _passCtrl,
        obscureText: _obscurePassword,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (v) {
          if (v == null || v.isEmpty) return "Mínimo 8 caracteres, 1 mayúscula, 1 número y 1 símbolo";
          final RegExp passPattern = RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$');
          if (!passPattern.hasMatch(v)) {
            return "Mínimo 8 caracteres, 1 mayúscula, 1 número y 1 símbolo (!@#\$&*~)";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: "NUEVA CONTRASEÑA",
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: Icon(Icons.lock_outline, color: naranjaLogo, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildBotonRestablecer() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [naranjaLogo, const Color(0xFFFF8C32)],
        ),
        boxShadow: [
          BoxShadow(
            color: naranjaLogo.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _actualizarPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const TextoAutomatico(
          "RESTABLECER",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
