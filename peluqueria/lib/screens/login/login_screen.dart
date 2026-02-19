import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_preferences.dart';
import '../../providers/locale_provider.dart';
import '../../config/traducciones.dart';
import '../contraseña/olvide_password_screen.dart';
import 'package:peluqueria/widget/texto_automatico.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final Color naranjaLogo = const Color(0xFFFF6B00);
  final Color negroSuave = const Color(0xFF2D2D2D);

  // --- NUEVOS PATRONES DE VALIDACIÓN ---
  // Usuario: letras, números o puntos. Mínimo 4 caracteres.
  final RegExp _userPattern = RegExp(r'^[a-zA-Z0-9.]{4,20}$');
  // Pass: 8+ chars, 1 Mayús, 1 Núm, 1 Símbolo (Igual que Signup)
  final RegExp _passPattern = RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$');

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final String? response = await AuthService().intentarLogin(
        _userController.text.trim(),
        _passController.text.trim(),
      );
      
      if (response == null || response == "CREDENCIALES_MAL" || response.contains("ERROR")) {
        _mostrarSnackBar("Usuario o contraseña incorrectos".tr(context), Colors.redAccent);
      } else {
        final prefs = UserPreferences();
        await prefs.guardarSesion(response, _passController.text.trim());
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _mostrarSnackBar("Error de conexión con el servidor".tr(context), Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TextoAutomatico(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _loginConGoogle() async {
    setState(() => _isLoading = true);
    try {
      final String? response = await AuthService().iniciarSesionConGoogle();
      if (response == null) return;
      
      if (response.startsWith("ERROR")) {
        _mostrarSnackBar(
          "Error de configuración (SHA-1). Contacta al administrador.".tr(context), 
          Colors.redAccent
        );
        return; 
      }
      
      final prefs = UserPreferences();
      await prefs.guardarSesion(response, "GOOGLE_AUTH");
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _mostrarSnackBar("Error inesperado en el inicio de sesión".tr(context), Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    _buildLogo(),
                    const SizedBox(height: 25),
                    TextoAutomatico(
                      "BERNAT",
                      style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: negroSuave, letterSpacing: 1.5),
                    ),
                    TextoAutomatico(
                      "EXPERIENCE",
                      style: TextStyle(fontSize: 12, letterSpacing: 6, fontWeight: FontWeight.w300, color: naranjaLogo),
                    ),
                    const SizedBox(height: 50),
                    _buildModernInput(
                      controller: _userController,
                      label: 'NOMBRE DE USUARIO'.tr(context),
                      icon: Icons.alternate_email_rounded,
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Introduce tu usuario".tr(context);
                        if (!_userPattern.hasMatch(v)) return "Usuario no válido (4-15 caracteres)".tr(context);
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildModernInput(
                      controller: _passController,
                      label: 'CONTRASEÑA'.tr(context),
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return "La contraseña es obligatoria".tr(context);
                        // Aplicamos el patrón robusto de config api+
                        if (!_passPattern.hasMatch(v)) return "Formato de contraseña incorrecto".tr(context);
                        return null;
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OlvidePasswordScreen())),
                        child: TextoAutomatico(
                          '¿Olvidaste tu clave?'.tr(context),
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator(color: naranjaLogo)
                        : Column(
                            children: [
                              _buildBotonEntrar(),
                              const SizedBox(height: 15),
                              _buildBotonGoogle(),
                            ],
                          ),
                    const SizedBox(height: 40),
                    _buildFooterRegistro(),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: _buildBotonIdioma(),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonIdioma() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: naranjaLogo.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(Icons.translate_rounded, color: naranjaLogo, size: 24),
      ),
      onSelected: (String lang) {
        Provider.of<LocaleProvider>(context, listen: false).setLocale(Locale(lang));
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'es', child: Text("🇪🇸 Español")),
        const PopupMenuItem(value: 'en', child: Text("🇬🇧 English")),
      ],
    );
  }

  Widget _buildBotonEntrar() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(colors: [naranjaLogo, const Color(0xFFFF8C32)]),
        boxShadow: [BoxShadow(color: naranjaLogo.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        child: TextoAutomatico(
          'INICIAR SESIÓN'.tr(context),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildBotonGoogle() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: OutlinedButton(
        onPressed: _loginConGoogle,
        style: OutlinedButton.styleFrom(side: BorderSide.none, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGoogleIcon(),
            const SizedBox(width: 12),
            TextoAutomatico(
              'Continuar con Google'.tr(context),
              style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterRegistro() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextoAutomatico('¿Eres nuevo aquí? '.tr(context), style: TextStyle(color: Colors.grey[600])),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/registro'),
          child: TextoAutomatico(
            'Crea una cuenta'.tr(context),
            style: TextStyle(color: naranjaLogo, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildModernInput({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false, required String? Function(String?) validator}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? !_isPasswordVisible : false,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: Icon(icon, color: naranjaLogo, size: 20),
          suffixIcon: isPassword ? IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey, size: 20), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: naranjaLogo.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Image.asset('assets/iconPeluqueria.png', height: 110, errorBuilder: (c, e, s) => Icon(Icons.cut, size: 80, color: naranjaLogo)),
    );
  }

  Widget _buildGoogleIcon() {
    return Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png', height: 24, width: 24);
  }
}