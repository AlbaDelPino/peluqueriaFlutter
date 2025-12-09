import 'package:flutter/material.dart';
import 'home_services_screen.dart';
import 'news_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabs = const [
      HomeServicesScreen(),
      NewsScreen(),
      ProfileScreen(),
    ];
  }

  static const primary = Color(0xFFFF8B00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( // 👈 asegura que el contenido no quede debajo de barras del sistema
        child: IndexedStack(index: _currentIndex, children: _tabs),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: primary,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 13,
          unselectedFontSize: 12,
          iconSize: 28,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 0 ? Icons.home_filled : Icons.home,
              ),
              label: 'Servicios',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 1 ? Icons.article_outlined : Icons.article,
              ),
              label: 'Noticias',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 2 ? Icons.person_2 : Icons.person,
              ),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
