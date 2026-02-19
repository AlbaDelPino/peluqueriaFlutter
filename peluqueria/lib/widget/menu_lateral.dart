import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../services/user_preferences.dart';
import '../../config/api_config.dart';
import '../screens/perfil/editar_perfil_screen.dart';
import '../screens/perfil/cambiar_password_screen.dart';
import '../../widget/texto_automatico.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  final Color naranjaLogo = const Color(0xFFFF6B00);
  final Color textoPrincipal = const Color(0xFF333333);

  // --- FUNCIÓN PARA LLAMADA DIRECTA ---
  Future<void> _hacerLlamada() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: '+34637849998',
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('No se pudo abrir el marcador telefónico');
      }
    } catch (e) {
      debugPrint('Error al intentar llamar: $e');
    }
  }

  // --- FUNCIÓN PARA WHATSAPP ---
  Future<void> _abrirWhatsApp() async {
    final Uri whatsappUri = Uri.parse(
      "https://wa.me/34637849998?text=Hola,%20me%20gustaría%20pedir%20información.",
    );
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('No se pudo abrir WhatsApp');
      }
    } catch (e) {
      debugPrint('Error al abrir WhatsApp: $e');
    }
  }

  // --- FUNCIÓN PARA ABRIR MAPAS ---
  Future<void> _abrirMapas() async {
    // Reemplaza con la dirección real o coordenadas de la peluquería
    final Uri mapUri = Uri.parse("https://www.google.com/maps/search/?api=1&query=Peluqueria+Bernat+Experience");
    try {
      if (await canLaunchUrl(mapUri)) {
        await launchUrl(mapUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error al abrir mapas: $e');
    }
  }

  Future<Map<String, String>> _obtenerDatosUsuario() async {
    final prefs = UserPreferences();
    final String tokenActual = await prefs.token;

    String nombre = await prefs.nombreUsuario;
    String imagen = await prefs.imagenUsuario;

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.meUrl),
        headers: {
          'Authorization': 'Bearer $tokenActual',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        nombre = decodedData['nombre'] ?? nombre;
        imagen = decodedData['imagen'] ?? imagen;
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
        final String cleanImg = imagen.contains(',') ? imagen.split(',').last : imagen;

        return Drawer(
          backgroundColor: Colors.white,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: naranjaLogo),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: cleanImg.isNotEmpty
                      ? MemoryImage(base64Decode(cleanImg))
                      : null,
                  child: cleanImg.isEmpty
                      ? Icon(Icons.person, size: 45, color: naranjaLogo)
                      : null,
                ),
                accountName: TextoAutomatico(
                  nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                accountEmail: const TextoAutomatico(
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
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditarPerfilScreen()),
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
                          MaterialPageRoute(builder: (context) => const CambiarPasswordScreen()),
                        );
                      },
                    ),
                    
                    const Divider(indent: 20, endIndent: 20),
                    
                    // --- SECCIÓN: CONTACTO ---
                    _buildMenuItem(
                      icon: Icons.phone_in_talk_outlined,
                      title: 'Llamar al Establecimiento',
                      onTap: () {
                        Navigator.pop(context);
                        _hacerLlamada();
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'WhatsApp Directo',
                      onTap: () {
                        Navigator.pop(context);
                        _abrirWhatsApp();
                      },
                    ),

                    const Divider(indent: 20, endIndent: 20),

                    // --- SECCIÓN: AYUDA Y SOPORTE ---
                    Padding(
                      padding: const EdgeInsets.only(left: 24, top: 10, bottom: 5),
                      child: TextoAutomatico(
                        "AYUDA Y SOPORTE",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.location_on_outlined,
                      title: '¿Cómo llegar?',
                      onTap: () {
                        Navigator.pop(context);
                        _abrirMapas();
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.info_outline_rounded,
                      title: 'Sobre la App',
                      onTap: () {
                        Navigator.pop(context);
                        // Mostramos un resumen propio en lugar del de Flutter
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              title: TextoAutomatico("Bernat Experience", style: TextStyle(color: naranjaLogo, fontWeight: FontWeight.bold)),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const TextoAutomatico("Versión 1.0.2", style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),
                                  const TextoAutomatico("Esta aplicación ha sido diseñada exclusivamente para los clientes de Bernat Experience."),
                                  const SizedBox(height: 10),
                                  const TextoAutomatico("• Gestiona tus citas.\n• Contacto directo con profesionales.\n• Historial de servicios."),
                                  const SizedBox(height: 15),
                                  const TextoAutomatico("© 2026 Bernat Experience. Todos los derechos reservados.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: TextoAutomatico("Cerrar", style: TextStyle(color: naranjaLogo)),
                                ),
                              ],
                            );
                          },
                        );
                      },
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
                      title: const TextoAutomatico(
                        'Cerrar Sesión',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                      ),
                      onTap: () async {
                        final prefs = UserPreferences();
                        await prefs.logout();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
      title: TextoAutomatico(
        title,
        style: TextStyle(color: textoPrincipal, fontSize: 15, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
    );
  }
}