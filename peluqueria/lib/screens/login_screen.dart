import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    // UI-only: reemplaza la pila y navega a la pantalla principal con BottomNavigationBar
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _onGoToSignUp() {
    Navigator.pushNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF8B00);

    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión'), backgroundColor: primary, elevation: 0, automaticallyImplyLeading: false),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Bienvenido', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Accede con tu cuenta', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 18),

                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.email)),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: _onLoginPressed,
                    child: const Text('Entrar'),
                  ),
                ),
                const SizedBox(height: 12),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('¿No tienes cuenta?'),
                  TextButton(onPressed: _onGoToSignUp, child: const Text('Regístrate', style: TextStyle(color: primary))),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
