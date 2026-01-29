import 'package:flutter/material.dart';
// 1. IMPORTA ESTE PAQUETE
import 'package:flutter/services.dart';
import 'package:peluqueria/services/user_preferences.dart';
import 'package:peluqueria/screens/login/login_screen.dart';
import 'package:peluqueria/screens/home_screens.dart';
import 'package:peluqueria/screens/login/signup_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  // Asegura que los bindings estén listos antes de llamar a SystemChrome
  WidgetsFlutterBinding.ensureInitialized();

  // 2. CONFIGURA LA ORIENTACIÓN VERTICAL AQUÍ
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Vertical normal
    DeviceOrientation.portraitDown, // Vertical invertido (opcional)
  ]);

  final prefs = UserPreferences();

  initializeDateFormatting('es_ES', null).then((_) {
    runApp(const MyApp());
  });
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
        // Usamos el color hexadecimal para ser consistentes con tu diseño
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6B00)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorObservers: [routeObserver],
      home: FutureBuilder<bool>(
        future: prefs.verificarTokenEnServidor(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
              ),
            );
          }

          if (snapshot.hasData && snapshot.data == true) {
            return const HomeScreens();
          } else {
            prefs.logout();
            return const LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreens(),
        '/registro': (context) => const SignupScreen(),
      },
    );
  }

  
}
