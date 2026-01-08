import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final Color naranjaLogo = const Color(0xFFFF6B00);
  final Color negroSuave = const Color(0xFF2D2D2D);

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _login() async {
    // 1. Validación básica local
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      _mostrarSnackBar("Por favor, rellena todos los campos", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String? response = await AuthService().intentarLogin(
        _userController.text.trim(),
        _passController.text.trim(),
      );

      // --- VALIDACIÓN ANTI-COLAPSO ---
      // Si la respuesta es nula o contiene el texto de error de tu servidor
      if (response == null ||
          response == "CREDENCIALES_MAL" ||
          response.contains("ERROR")) {
        if (mounted) {
          _mostrarSnackBar(
            "Usuario o contraseña incorrectos",
            Colors.redAccent,
          );
        }
      } else {
        // Si no es el error plano, procedemos a guardar (es un JSON válido)
        final prefs = UserPreferences();
        await prefs.guardarSesion(response, _passController.text.trim());

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      // Captura errores de red o formato inesperado
      _mostrarSnackBar("Error de conexión con el servidor", Colors.redAccent);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. LOGO CON SOMBRA
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: naranjaLogo.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/iconPeluqueria.png',
                  height: 110,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.cut, size: 80, color: naranjaLogo),
                ),
              ),
              const SizedBox(height: 25),

              // 2. TEXTO CORPORATIVO
              Text(
                "BERNAT",
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: negroSuave,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                "EXPERIENCE",
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 6,
                  fontWeight: FontWeight.w300,
                  color: naranjaLogo,
                ),
              ),
              const SizedBox(height: 50),

              // 3. CAMPOS DE ENTRADA
              _buildModernInput(
                controller: _userController,
                label: "Nombre de usuario",
                icon: Icons.alternate_email_rounded,
              ),
              const SizedBox(height: 20),
              _buildModernInput(
                controller: _passController,
                label: "Contraseña",
                icon: Icons.lock_outline_rounded,
                isPassword: true,
              ),

              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "¿Olvidaste tu clave?",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 4. BOTÓN DE ACCESO
              _isLoading
                  ? CircularProgressIndicator(color: naranjaLogo)
                  : _buildBotonEntrar(),

              const SizedBox(height: 40),

              // 5. ENLACE DE REGISTRO
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "¿Eres nuevo aquí? ",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/registro'),
                    child: Text(
                      "Crea una cuenta",
                      style: TextStyle(
                        color: naranjaLogo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotonEntrar() {
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
        onPressed: _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          "INICIAR SESIÓN",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? !_isPasswordVisible : false,
        cursorColor: naranjaLogo,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(icon, color: naranjaLogo, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}
