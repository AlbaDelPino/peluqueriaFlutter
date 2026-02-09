import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_preferences.dart';
import '../contraseña/olvide_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // CLAVE PARA EL FORMULARIO (Igual que en Signup)
  final _formKey = GlobalKey<FormState>();

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

  // --- LÓGICA DE LOGIN CON VALIDACIÓN DE FORMULARIO ---
  void _login() async {
    // Validamos el formulario antes de seguir
    if (!_formKey.currentState!.validate()) return;

    // Cerramos el teclado
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final String? response = await AuthService().intentarLogin(
        _userController.text.trim(),
        _passController.text.trim(),
      );
      print("RESPUESTA REAL DEL SERVIDOR: '$response'"); // <--- AÑADE ESTO

      if (response == "CUENTA_NO_VERIFICADA") {
        _mostrarDialogoNoVerificado();
      } else if (response == null ||
          response == "CREDENCIALES_MAL" ||
          response.contains("ERROR")) {
        _mostrarSnackBar("Usuario o contraseña incorrectos", Colors.redAccent);
      } else {
        final prefs = UserPreferences();
        await prefs.guardarSesion(response, _passController.text.trim());
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _mostrarSnackBar("Error de conexión con el servidor", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LÓGICA DE GOOGLE ---
  void _loginConGoogle() async {
    setState(() => _isLoading = true);
    try {
      final String? response = await AuthService().iniciarSesionConGoogle();
      if (response == null) return;

      if (response == "ERROR_SERVIDOR" || response == "ERROR_CONEXION") {
        _mostrarSnackBar("Error al conectar con Google", Colors.redAccent);
      } else {
        final prefs = UserPreferences();
        await prefs.guardarSesion(response, "GOOGLE_AUTH");
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _mostrarSnackBar("Ocurrió un error inesperado", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarDialogoNoVerificado() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Cuenta no activa",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Tu cuenta aún no ha sido verificada. Revisa tu correo electrónico.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("ENTENDIDO", style: TextStyle(color: naranjaLogo)),
          ),
        ],
      ),
    );
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Form(
            key: _formKey, // ASIGNACIÓN DE LA LLAVE
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                _buildLogo(),
                const SizedBox(height: 25),
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

                // INPUT USUARIO CON VALIDATOR
                _buildModernInput(
                  controller: _userController,
                  label: "NOMBRE DE USUARIO",
                  icon: Icons.alternate_email_rounded,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? "Introduce tu usuario" : null,
                ),

                const SizedBox(height: 20),

                // INPUT PASSWORD CON VALIDATOR
                _buildModernInput(
                  controller: _passController,
                  label: "CONTRASEÑA",
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: (v) => (v == null || v.length < 4)
                      ? "Mínimo 4 caracteres"
                      : null,
                ),

                // BOTÓN OLVIDAR CONTRASEÑA
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OlvidePasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "¿Olvidaste tu clave?",
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

                // Registro
                _buildFooterRegistro(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET REUTILIZABLE (Estilo Signup) ---
  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? !_isPasswordVisible : false,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: Icon(icon, color: naranjaLogo, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                    size: 20,
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

  Widget _buildLogo() {
    return Container(
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
        errorBuilder: (c, e, s) =>
            Icon(Icons.cut, size: 80, color: naranjaLogo),
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
        style: OutlinedButton.styleFrom(
          side: BorderSide
              .none, // Quitamos el borde del botón porque el Container ya tiene uno
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGoogleIcon(), // <--- Aquí llamamos a tu nuevo widget de imagen
            const SizedBox(width: 12),
            const Text(
              "Continuar con Google",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
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
        Text("¿Eres nuevo aquí? ", style: TextStyle(color: Colors.grey[600])),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/registro'),
          child: Text(
            "Crea una cuenta",
            style: TextStyle(color: naranjaLogo, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleIcon() {
    return Image.network(
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
      height: 24,
      width: 24,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      },
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.g_mobiledata, color: Colors.blue, size: 30),
    );
  }
}
