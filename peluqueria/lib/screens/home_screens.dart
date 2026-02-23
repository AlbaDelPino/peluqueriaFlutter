import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/user_preferences.dart'; // Ajustado a tu path
import '../widget/menu_lateral.dart';
import 'servicios/servicios_sreen.dart';
import 'citas/mis_citas_screen.dart';
import 'perfil/perfil_screen.dart';
import 'galeriaImagen/galeria_screens.dart';
import '../providers/locale_provider.dart';
import 'inicio_contenido.dart';
import '../config/api_config.dart';
import '../services/notification_service.dart';
import '../models/cita/cita_model.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  int _selectedIndex = 0;
  final prefs = UserPreferences();

  final List<Widget> _paginas = [
    InicioContenido(),
    const ServiciosScreen(),
    const MisCitasScreen(),
    const GaleriaServiciosScreen(),
    const PerfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _sincronizarNotificacionesCitas();
  }

  Future<void> _sincronizarNotificacionesCitas() async {
    debugPrint("🚀 [DEBUG] Iniciando sincronización...");
    try {
      final idCliente = await prefs.userId;
      final token = await prefs.token;

      final url = ApiConfig.getCitasByCliente(idCliente);
      final resp = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resp.statusCode == 200) {
        final List<dynamic> citasJson = json.decode(resp.body);
        final notifService = NotificationService(); // Instancia Singleton

        for (var json in citasJson) {
          try {
            // Convertimos el JSON al modelo Cita
            Cita cita = Cita.fromJson(json);
            
            // Usamos el método de instancia de tu nuevo servicio
            await notifService.scheduleReminders(cita);
          } catch (e) {
            debugPrint("❌ [DEBUG] Error en cita individual: $e");
          }
        }
        debugPrint("📅 [DEBUG] Sincronización completada.");
      }
    } catch (e) {
      debugPrint("⚠️ [DEBUG] Error sincronización: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    const Color naranjaLogo = Color(0xFFFF6B00);
    final provider = Provider.of<LocaleProvider>(context);
    final bool isEn = provider.locale.languageCode == 'en';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("BERNAT EXPERIENCE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              provider.setLocale(provider.locale.languageCode == 'es' ? const Locale('en') : const Locale('es'));
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: naranjaLogo,
        elevation: 0,
      ),
      drawer: const MenuLateral(),
      body: IndexedStack(index: _selectedIndex, children: _paginas),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: naranjaLogo,
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_rounded), label: isEn ? 'Home' : 'Inicio'),
          BottomNavigationBarItem(icon: const Icon(Icons.content_cut_rounded), label: isEn ? 'Services' : 'Servicios'),
          BottomNavigationBarItem(icon: const Icon(Icons.event_note_rounded), label: isEn ? 'Appointments' : 'Mis citas'),
          BottomNavigationBarItem(icon: const Icon(Icons.collections_rounded), label: isEn ? 'Gallery' : 'Galería'),
          BottomNavigationBarItem(icon: const Icon(Icons.person_rounded), label: isEn ? 'Profile' : 'Perfil'),
        ],
      ),
    );
  }
}