import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _userController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _dirController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Paleta de colores BERNAT
  final Color naranjaLogo = const Color(0xFFFF6B00);
  final Color negroSuave = const Color(0xFF2D2D2D);

  final RegExp _emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final RegExp _phonePattern = RegExp(r'^[0-9]{9}$');
  Future<void> _ejecutarRegistro() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    // Asegúrate de que esta IP sea la correcta de tu servidor actual
    const String urlApi =
        'http://10.217.44.95:8082/api/auth/signup/cliente/public';

    final signupData = {
      "username": _userController.text.trim(),
      "nombre": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "telefono": int.tryParse(_phoneController.text.trim()) ?? 0,
      "contrasenya": _passController.text,
      "estado":
          true, // El estado lógico es activo, pero "verificado" será false en BD
      "rol": "ROLE_CLIENTE",
      "direccion": _dirController.text.trim(),
      "alergenos": "",
      "imagen": null,
    };

    try {
      final response = await http.post(
        Uri.parse(urlApi),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(signupData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ÉXITO: Mostramos un diálogo informativo en lugar de solo un mensaje rápido
        if (mounted) {
          _mostrarDialogoVerificacion();
        }
      } else {
        _mostrarMensaje(
          "El usuario o email ya están registrados",
          Colors.redAccent,
        );
      }
    } catch (e) {
      _mostrarMensaje("Error de conexión con el servidor", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarDialogoVerificacion() {
    showDialog(
      context: context,
      barrierDismissible: false, // Obliga a interactuar con el botón
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Icon(
            Icons.mark_email_read_outlined,
            color: naranjaLogo,
            size: 50,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "¡REGISTRO CASI COMPLETADO!",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Text(
                "Hemos enviado un enlace de activación a:\n${_emailController.text.trim()}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              const Text(
                "Por favor, revisa tu bandeja de entrada (o spam) y pulsa en el enlace para poder iniciar sesión.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el diálogo
                  Navigator.pop(context); // Vuelve a la pantalla de Login
                },
                child: Text(
                  "ENTENDIDO",
                  style: TextStyle(
                    color: naranjaLogo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarMensaje(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
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
        title: Text(
          "UNIRSE A BERNAT",
          style: TextStyle(
            color: negroSuave,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Icono pequeño para mantener identidad
              _buildModernInput(
                controller: _userController,
                label: "USUARIO",
                icon: Icons.person_outline,
                validator: (v) =>
                    (v == null || v.length < 4) ? 'Mínimo 4 caracteres' : null,
              ),
              _buildModernInput(
                controller: _nameController,
                label: "NOMBRE COMPLETO",
                icon: Icons.badge_outlined,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Indica tu nombre' : null,
              ),
              _buildModernInput(
                controller: _emailController,
                label: "EMAIL",
                icon: Icons.email_outlined,
                type: TextInputType.emailAddress,
                validator: (v) => (v == null || !_emailPattern.hasMatch(v))
                    ? 'Email no válido'
                    : null,
              ),
              _buildModernInput(
                controller: _phoneController,
                label: "TELÉFONO",
                icon: Icons.phone_android,
                type: TextInputType.number,
                validator: (v) => (v == null || !_phonePattern.hasMatch(v))
                    ? 'Deben ser 9 números'
                    : null,
              ),

              // Campo Password Moderno
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextFormField(
                  controller: _passController,
                  obscureText: _obscurePassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: "CONTRASEÑA",
                    labelStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: naranjaLogo,
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
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
                  validator: (v) => (v != null && v.length >= 6)
                      ? null
                      : 'Mínimo 6 caracteres',
                ),
              ),

              _buildModernInput(
                controller: _dirController,
                label: "DIRECCIÓN",
                icon: Icons.location_on_outlined,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo obligatorio' : null,
              ),

              const SizedBox(height: 30),

              // Botón con Degradado BERNAT
              _isLoading
                  ? CircularProgressIndicator(color: naranjaLogo)
                  : Container(
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
                        onPressed: _ejecutarRegistro,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "CREAR MI CUENTA",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
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
    TextInputType type = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        autovalidateMode: AutovalidateMode.onUserInteraction,
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
        validator: validator,
      ),
    );
  }
}
