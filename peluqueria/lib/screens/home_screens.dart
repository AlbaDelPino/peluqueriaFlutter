import 'package:flutter/material.dart';

import '../services/user_preferences.dart';
import '../widget/menu_lateral.dart';
import 'servicios/servicios_sreen.dart';
import 'citas/mis_citas_screen.dart';
import 'perfil/perfil_screen.dart';
import 'inicio_contenido.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  int _selectedIndex = 0;
  final prefs = UserPreferences();

  // Definimos las páginas como una lista fija para optimizar el rendimiento
  final List<Widget> _paginas = [
    InicioContenido(), // Índice 0
    const ServiciosScreen(), // Índice 1
    const MisCitasScreen(),
    const PerfilScreen(), // Índice 2
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

    return Scaffold(
      backgroundColor: Colors.white,

      // 1. APPBAR MODERNA
      appBar: AppBar(
        title: const Text(
          "BERNAT EXPERIENCE",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: naranjaLogo,
        elevation: 0,
      ),

      // 2. MENÚ LATERAL (DRAWER)
      drawer: const MenuLateral(),

      // 3. CUERPO DE LA APP (Mantiene el estado de las pestañas)
      body: IndexedStack(index: _selectedIndex, children: _paginas),

      // 4. BARRA DE NAVEGACIÓN INFERIOR (ESTILIZADA)
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.content_cut_rounded),
              activeIcon: Icon(Icons.content_cut_rounded),
              label: 'Servicios',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined),
              activeIcon: Icon(Icons.event_note_rounded),
              label: 'Mis citas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
