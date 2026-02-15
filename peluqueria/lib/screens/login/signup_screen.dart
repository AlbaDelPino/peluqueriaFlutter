import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../providers/locale_provider.dart';
import '../../config/traducciones.dart';
import 'package:peluqueria/widget/texto_automatico.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final _userController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();

  bool _isLoading = false;
  bool _aceptaTerminos = false;
  bool _obscurePassword = true;

  final Color naranjaLogo = const Color(0xFFFF6B00);
  final Color negroSuave = const Color(0xFF2D2D2D);

  // --- PATRONES DE VALIDACIÓN ---
  final RegExp _userPattern = RegExp(r'^[a-zA-Z0-9_-]{4,15}$');
  final RegExp _emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final RegExp _phonePattern = RegExp(r'^[0-9]{9}$');

  @override
  void dispose() {
    _userController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _ejecutarRegistro() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_aceptaTerminos) {
      _mostrarMensaje("Acepta los términos".tr(context), Colors.orange);
      return;
    }
    
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final signupData = {
      "username": _userController.text.trim(),
      "nombre": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "telefono": int.tryParse(_phoneController.text.trim()) ?? 0,
      "contrasenya": _passController.text,
      "estado": true,
      "rol": "ROLE_CLIENTE",
      "alergenos": "",
      "imagen": null,
    };

    try {
      final response = await _authService.register(signupData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) _mostrarDialogoVerificacion();
      } else {
        _mostrarMensaje("El usuario o email ya están registrados".tr(context), Colors.redAccent);
      }
    } catch (e) {
      _mostrarMensaje("Error de conexión con el servidor".tr(context), Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarTerminos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: TextoAutomatico(
          "Términos y Condiciones".tr(context),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextoAutomatico(
                "Los datos recogidos serán los mínimos necesarios, no se destinarán a otros fines ni se cederán a terceros y se conservarán únicamente durante el tiempo necesario para su finalidad.".tr(context),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 15),
              TextoAutomatico(
                "El cliente podrá ejercer sus derechos de acceso, rectificación, supresión, oposición, limitación del tratamiento y portabilidad solicitándolo al responsable del tratamiento.".tr(context),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 15),
              TextoAutomatico(
                "Asimismo, AUTORIZO al salón a realizar y utilizar imágenes (fotografías y/o vídeos) del resultado del servicio con fines informativos y promocionales del propio salón.".tr(context),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextoAutomatico("CERRAR".tr(context), style: TextStyle(color: naranjaLogo, fontWeight: FontWeight.bold)),
          ),
        ],
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
          "UNIRSE A BERNAT".tr(context),
          style: TextStyle(color: negroSuave, fontWeight: FontWeight.w900, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildModernInput(
                controller: _userController,
                label: "USUARIO".tr(context),
                icon: Icons.person_outline,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Campo obligatorio".tr(context);
                  if (!_userPattern.hasMatch(v)) return "Usuario no válido (4-15 caracteres)".tr(context);
                  return null;
                },
              ),
              _buildModernInput(
                controller: _nameController,
                label: "NOMBRE COMPLETO".tr(context),
                icon: Icons.badge_outlined,
                validator: (v) => (v == null || v.isEmpty) ? "Indica tu nombre".tr(context) : null,
              ),
              _buildModernInput(
                controller: _emailController,
                label: "EMAIL".tr(context),
                icon: Icons.email_outlined,
                type: TextInputType.emailAddress,
                validator: (v) => (v == null || !_emailPattern.hasMatch(v)) ? "Email no válido".tr(context) : null,
              ),
              _buildModernInput(
                controller: _phoneController,
                label: "TELÉFONO".tr(context),
                icon: Icons.phone_android,
                type: TextInputType.number,
                validator: (v) => (v == null || !_phonePattern.hasMatch(v)) ? "Deben ser 9 números".tr(context) : null,
              ),
              _buildPasswordInput(),
              _buildCheckTerminos(),
              const SizedBox(height: 30),
              _isLoading
                  ? CircularProgressIndicator(color: naranjaLogo)
                  : _buildBotonRegistro(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        controller: _passController,
        obscureText: _obscurePassword,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: "CONTRASEÑA".tr(context),
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: Icon(Icons.lock_outline, color: naranjaLogo, size: 20),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 20),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
        validator: (v) => (v != null && v.length >= 6) ? null : "Mínimo 6 caracteres".tr(context),
      ),
    );
  }

  Widget _buildCheckTerminos() {
    return Row(
      children: [
        Checkbox(
          value: _aceptaTerminos,
          activeColor: naranjaLogo,
          onChanged: (value) => setState(() => _aceptaTerminos = value!),
        ),
        Expanded(
          child: GestureDetector(
            onTap: _mostrarTerminos,
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 13),
                children: [
                  TextSpan(text: "Acepto los ".tr(context)),
                  TextSpan(
                    text: "términos y condiciones".tr(context),
                    style: TextStyle(color: naranjaLogo, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBotonRegistro() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(colors: [naranjaLogo, const Color(0xFFFF8C32)]),
        boxShadow: [BoxShadow(color: naranjaLogo.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: ElevatedButton(
        onPressed: _ejecutarRegistro,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        child: TextoAutomatico(
          "CREAR MI CUENTA".tr(context),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  void _mostrarDialogoVerificacion() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Icon(Icons.check_circle_outline, color: naranjaLogo, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextoAutomatico("¡REGISTRO COMPLETADO!".tr(context), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 15),
            TextoAutomatico("Tu cuenta ha sido creada correctamente.".tr(context), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: TextoAutomatico("ENTENDIDO".tr(context), style: TextStyle(color: naranjaLogo, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarMensaje(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: TextoAutomatico(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  Widget _buildModernInput({required TextEditingController controller, required String label, required IconData icon, TextInputType type = TextInputType.text, required String? Function(String?) validator}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: Icon(icon, color: naranjaLogo, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
        validator: validator,
      ),
    );
  }
}