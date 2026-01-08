import 'package:flutter/material.dart';
import 'package:peluqueria/services/user_preferences.dart';
import 'package:peluqueria/screens/login/login_screen.dart';
import 'package:peluqueria/screens/home_screens.dart';
import 'package:peluqueria/screens/login/signup_screen.dart';

// 1. DEFINICIÓN DEL OBSERVADOR DE RUTAS (Debe ser global para acceder desde Perfil)
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  // Aseguramos que los bindings de Flutter estén listos
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos las preferencias
  final prefs = UserPreferences();
  await prefs.initPrefs();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = UserPreferences();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bernat Experience',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      // 2. REGISTRO DEL OBSERVADOR
      // Esto permite que pantallas como Perfil sepan cuándo vuelven a estar visibles
      navigatorObservers: [routeObserver],

      initialRoute: (prefs.esSesionValida) ? '/home' : '/login',

      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreens(),
        '/registro': (context) => const SignupScreen(),
      },
    );
  }
}
