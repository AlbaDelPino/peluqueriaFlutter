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

class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  int _selectedIndex = 0;
  final prefs = UserPreferences();

  // Lista de páginas
  final List<Widget> _paginas = [
    InicioContenido(),                // 0
    const ServiciosScreen(),          // 1
    const MisCitasScreen(),           // 2
    const GaleriaServiciosScreen(),   // 3
    const PerfilScreen(),             // 4
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Colores corporativos
    const Color naranjaLogo = Color(0xFFFF6B00);
    
    // Obtenemos el provider del idioma
    final provider = Provider.of<LocaleProvider>(context);
    final bool isEn = provider.locale.languageCode == 'en';

    return Scaffold(
      backgroundColor: Colors.white,

      // 1. APPBAR CON CAMBIO DE IDIOMA
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
            tooltip: isEn ? "Change Language" : "Cambiar Idioma",
            onPressed: () {
              if (provider.locale.languageCode == 'es') {
                provider.setLocale(const Locale('en'));
              } else {
                provider.setLocale(const Locale('es'));
              }
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: naranjaLogo,
        elevation: 0,
      ),

      // 2. MENÚ LATERAL
      drawer: const MenuLateral(),

      // 3. CUERPO (IndexedStack para no perder el scroll al cambiar de pestaña)
      body: IndexedStack(
        index: _selectedIndex, 
        children: _paginas
      ),

      // 4. BARRA DE NAVEGACIÓN DINÁMICA
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
          backgroundColor: Colors.white,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
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
              icon: const Icon(Icons.collections_rounded), // Icono cambiado para Galería
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