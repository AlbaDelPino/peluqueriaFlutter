import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/user_preferences.dart';
import '../../config/api_config.dart';
import '../screens/perfil/editar_perfil_screen.dart';
import '../screens/perfil/cambiar_password_screen.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  final Color naranjaLogo = const Color(0xFFFF6B00);
  final Color textoPrincipal = const Color(0xFF333333);

  /// Obtiene los datos directamente de la API para asegurar que la foto esté actualizada
  Future<Map<String, String>> _obtenerDatosUsuario() async {
    final prefs = UserPreferences();
    final String tokenActual = await prefs.token;

    // Valores iniciales (por si la API tarda o falla)
    String nombre = await prefs.nombreUsuario;
    String imagen = await prefs.imagenUsuario;

    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.meUrl),
            headers: {
              'Authorization': 'Bearer $tokenActual',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        nombre = decodedData['nombre'] ?? nombre;
        imagen = decodedData['imagen'] ?? imagen;

        // Actualizamos preferencias para que el resto de la app tenga los datos nuevos
      }
    } catch (e) {
      debugPrint("Error de red en MenuLateral: $e");
    }

    return {'nombre': nombre, 'imagen': imagen};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _obtenerDatosUsuario(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Drawer(
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
            ),
          );
        }

        final String nombre = snapshot.data!['nombre']!;
        final String imagen = snapshot.data!['imagen']!;

        // Limpiamos el Base64 igual que en la pantalla de Perfil
        final String cleanImg = imagen.contains(',')
            ? imagen.split(',').last
            : imagen;

        return Drawer(
          backgroundColor: Colors.white,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: naranjaLogo),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  // Lógica de visualización idéntica a PerfilScreen
                  backgroundImage: cleanImg.isNotEmpty
                      ? MemoryImage(base64Decode(cleanImg))
                      : null,
                  child: cleanImg.isEmpty
                      ? Icon(Icons.person, size: 45, color: naranjaLogo)
                      : null,
                ),
                accountName: Text(
                  nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
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
                      onTap: () async {
                        Navigator.pop(context);
                        // Esperamos el resultado por si hubo cambios
                        await Navigator.push(
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
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                      title: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () async {
                        final prefs = UserPreferences();
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
