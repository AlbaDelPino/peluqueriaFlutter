import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_preferences.dart';
import '../widget/menu_lateral.dart';
import 'servicios/servicios_sreen.dart';
import 'citas/mis_citas_screen.dart';
import 'perfil/perfil_screen.dart';
import 'galeriaImagen/galeria_screens.dart';
import '../providers/locale_provider.dart';
import 'inicio_contenido.dart';
import 'dart:convert'; 
import 'package:http/http.dart' as http; 
import '../config/api_config.dart'; 
import '../services/notification_service.dart'; 

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
        final List<dynamic> citas = json.decode(resp.body);
        debugPrint("📅 [DEBUG] Procesando ${citas.length} citas...");
        
        for (var cita in citas) {
          try {
            final id = cita['id'];
            final f = cita['fecha'];
            final h = cita['horaInicio']; 

            if (f != null && h != null) {
              String fechaLimpia = f.toString().split('T')[0];
              DateTime fechaCita = DateTime.parse("$fechaLimpia $h");

              debugPrint("🔔 [DEBUG] Programando Recordatorio para Cita ID $id a las $fechaCita");

              await NotificationService.programarRecordatorioCita(
                int.parse(id.toString()), 
                fechaCita
              );
            }
          } catch (e) {
            debugPrint("❌ [DEBUG] Error en cita individual: $e");
          }
        }
      }
    } catch (e) {
      debugPrint("⚠️ [DEBUG] CRASH TOTAL: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color naranjaLogo = Color(0xFFFF6B00);
    final provider = Provider.of<LocaleProvider>(context);
    final bool isEn = provider.locale.languageCode == 'en';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "BERNAT EXPERIENCE",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              provider.setLocale(
                provider.locale.languageCode == 'es' 
                ? const Locale('en') 
                : const Locale('es')
              );
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: naranjaLogo,
        elevation: 0,
      ),
      drawer: const MenuLateral(),
      
      body: IndexedStack(
        index: _selectedIndex, 
        children: _paginas
      ),

      // BOTÓN DE PRUEBA RÁPIDA
      floatingActionButton: FloatingActionButton(
        backgroundColor: naranjaLogo,
        child: const Icon(Icons.notification_add, color: Colors.white),
        onPressed: () async {
          // Programamos una notificación para dentro de 5 segundos
          DateTime pruebaTime = DateTime.now().add(const Duration(seconds: 5));
          
          await// Prueba rápida en el botón naranja
NotificationService.programarRecordatorioCita(
  888, 
  DateTime.now().add(Duration(seconds: 10 + 3600)) // Le sumamos 1h y 10 seg para que el aviso de "1h antes" sea dentro de 10 seg
);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEn ? "Testing in 5s... Lock your phone!" : "Probando en 5s... ¡Bloquea el móvil!"),
              backgroundColor: Colors.black87,
            ),
          );
        },
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: naranjaLogo,
          unselectedItemColor: Colors.grey[400],
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              label: isEn ? 'Home' : 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.content_cut_rounded),
              label: isEn ? 'Services' : 'Servicios',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.event_note_rounded),
              label: isEn ? 'Appointments' : 'Mis citas',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.collections_rounded),
              label: isEn ? 'Gallery' : 'Galería',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_rounded),
              label: isEn ? 'Profile' : 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}