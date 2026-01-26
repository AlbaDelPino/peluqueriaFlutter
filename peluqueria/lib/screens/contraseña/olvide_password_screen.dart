import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'restablecer_password_screen.dart';

class OlvidePasswordScreen extends StatefulWidget {
  const OlvidePasswordScreen({super.key});

  @override
  State<OlvidePasswordScreen> createState() => _OlvidePasswordScreenState();
}

class _OlvidePasswordScreenState extends State<OlvidePasswordScreen> {
  // CLAVE PARA VALIDACIÓN
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  // Paleta de colores BERNAT
  final Color naranjaLogo = const Color(0xFFFF6B00);
  final Color negroSuave = const Color(0xFF2D2D2D);
  final RegExp _emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  Future<void> _procesarEnvio() async {
    // Validar el formulario antes de proceder
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();

    setState(() => _isLoading = true);

    final urlString =
        'http://192.168.7.13:8082/api/auth/forgot-password?email=$email';

    try {
      final response = await http.post(Uri.parse(urlString));

      if (response.statusCode == 200) {
        _mostrarMensaje("Código enviado correctamente", Colors.green);

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestablecerPasswordScreen(email: email),
          ),
        );
      } else {
        _mostrarMensaje(
          "No encontramos una cuenta con ese email",
          Colors.redAccent,
        );
      }
    } catch (e) {
      _mostrarMensaje("Error de conexión con el servidor", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          "RECUPERAR CUENTA",
          style: TextStyle(
            color: negroSuave,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Form(
          key: _formKey, // ASIGNACIÓN DE LA LLAVE
          child: Column(
            children: [
              const SizedBox(height: 20),
              Icon(Icons.mail_lock_outlined, size: 100, color: naranjaLogo),
              const SizedBox(height: 30),
              Text(
                "Introduce tu email y te enviaremos un código para restablecer tu contraseña.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // CAMPO EMAIL VALIDADO
              _buildModernInput(
                controller: _emailController,
                label: "CORREO ELECTRÓNICO",
                icon: Icons.email_outlined,
                validator: (v) {
                  if (v == null || v.isEmpty) return "El email es obligatorio";
                  if (!_emailPattern.hasMatch(v))
                    return "Formato de email no válido";
                  return null;
                },
              ),

              const SizedBox(height: 40),

              _isLoading
                  ? CircularProgressIndicator(color: naranjaLogo)
                  : _buildBotonEnviar(),
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
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
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

  Widget _buildBotonEnviar() {
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
        onPressed: _procesarEnvio,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          "ENVIAR CÓDIGO",
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
