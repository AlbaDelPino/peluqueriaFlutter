import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/user_preferences.dart';
import '../screens/perfil/editar_perfil_screen.dart';
import '../screens/perfil/cambiar_password_screen.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  final Color naranjaLogo = const Color(0xFFFF6B00);
  final Color textoPrincipal = const Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    final prefs = UserPreferences();

    // Usamos FutureBuilder porque obtener datos de Secure Storage es asíncrono
    return FutureBuilder(
      future: Future.wait([
        prefs.nombreUsuario,
        prefs.imagenUsuario,
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        // Mientras carga, mostramos un Drawer vacío con un loader
        if (!snapshot.hasData) {
          return const Drawer(child: Center(child: CircularProgressIndicator()));
        }

        final String nombre = snapshot.data![0];
        final String imagen = snapshot.data![1];

        return Drawer(
          backgroundColor: Colors.white,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: naranjaLogo),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: imagen.isNotEmpty
                      ? MemoryImage(base64Decode(imagen))
                      : null,
                  child: imagen.isEmpty
                      ? Icon(Icons.person, size: 45, color: naranjaLogo)
                      : null,
                ),
                accountName: Text(
                  nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                accountEmail: const Text(
                  "Cliente Bernat Experience",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildMenuItem(
                      icon: Icons.home_outlined,
                      title: 'Inicio',
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildMenuItem(
                      icon: Icons.edit_note_rounded,
                      title: 'Editar mis Datos',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditarPerfilScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.lock_reset_outlined,
                      title: 'Seguridad y Contraseña',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CambiarPasswordScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(indent: 20, endIndent: 20),
                    _buildMenuItem(
                      icon: Icons.support_agent_outlined,
                      title: 'Ayuda y Soporte',
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                      title: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () async {
                        await prefs.logout();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: naranjaLogo),
      title: Text(
        title,
        style: TextStyle(
          color: textoPrincipal,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}