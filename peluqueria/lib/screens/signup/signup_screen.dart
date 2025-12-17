import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Controllers
  final _userCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _alergenosCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _observacionCtrl = TextEditingController();

  bool _obscure = true;

  void _nextPage() {
    // Validaciones por paso
    if (_currentPage == 0) {
      if (_userCtrl.text.trim().isEmpty || _nameCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty || _confirmPassCtrl.text.trim().isEmpty) {
        _showError("Completa todos los campos del paso 1");
        return;
      }
      if (_passCtrl.text.trim() != _confirmPassCtrl.text.trim()) {
        _showError("Las contraseñas no coinciden");
        return;
      }
    } else if (_currentPage == 1) {
      if (_emailCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) {
        _showError("Completa todos los campos del paso 2");
        return;
      }
    } else if (_currentPage == 2) {
      if (_alergenosCtrl.text.trim().isEmpty || _direccionCtrl.text.trim().isEmpty || _observacionCtrl.text.trim().isEmpty) {
        _showError("Completa todos los campos del paso 3");
        return;
      }
      _onCreateAccountPressed();
      return;
    }

    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _onCreateAccountPressed() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.signup(
      username: _userCtrl.text.trim(),
      nombre: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      telefono: _phoneCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      alergenos: _alergenosCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
      observacion: _observacionCtrl.text.trim(),
    );
    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } else {
      _showError("Error al crear cuenta");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF8B00);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/iconPeluqueria.png'),
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Crear cuenta',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 300,
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      children: [
                        // Paso 1
                        _buildStep([
                          TextField(controller: _userCtrl, decoration: const InputDecoration(labelText: 'Usuario')),
                          const SizedBox(height: 12),
                          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nombre completo')),
                          const SizedBox(height: 12),
                          TextField(controller: _passCtrl, obscureText: _obscure, decoration: const InputDecoration(labelText: 'Contraseña')),
                          const SizedBox(height: 12),
                          TextField(controller: _confirmPassCtrl, obscureText: _obscure, decoration: const InputDecoration(labelText: 'Confirmar contraseña')),
                        ]),
                        // Paso 2
                        _buildStep([
                          TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Correo electrónico')),
                          const SizedBox(height: 12),
                          TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Teléfono')),
                        ]),
                        // Paso 3
                        _buildStep([
                          TextField(controller: _alergenosCtrl, decoration: const InputDecoration(labelText: 'Alérgenos')),
                          const SizedBox(height: 12),
                          TextField(controller: _direccionCtrl, decoration: const InputDecoration(labelText: 'Dirección')),
                          const SizedBox(height: 12),
                          TextField(controller: _observacionCtrl, decoration: const InputDecoration(labelText: 'Observación')),
                        ]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                            onPressed: _prevPage,
                            child: const Text("Atrás"),
                          ),
                        ),
                      if (_currentPage > 0) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: primary),
                          onPressed: _nextPage,
                          child: Text(_currentPage == 2 ? "Crear cuenta" : "Siguiente"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿Tienes cuenta?'),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Inicia sesión', style: TextStyle(color: primary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(children: children),
    );
  }
}
