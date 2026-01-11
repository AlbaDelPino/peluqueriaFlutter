import 'package:flutter/material.dart';
import 'package:peluqueria/services/user_preferences.dart';
import 'package:peluqueria/screens/login/login_screen.dart';
import 'package:peluqueria/screens/home_screens.dart';
import 'package:peluqueria/screens/login/signup_screen.dart';

// 1. DEFINICIÓN DEL OBSERVADOR DE RUTAS
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Nota: Con Secure Storage, el initPrefs ya no es estrictamente necesario
  // si no usas SharedPreferences, pero lo dejamos si tienes lógica mixta.
  final prefs = UserPreferences();
  // await prefs.initPrefs(); .0

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
      navigatorObservers: [routeObserver],

      // Usamos home con un FutureBuilder para validar el token contra el servidor
      home: FutureBuilder<bool>(
        future: prefs.verificarTokenEnServidor(),
        builder: (context, snapshot) {
          // Mientras comprueba con el backend, mostramos una pantalla de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.orange),
              ),
            );
          }

          // Si el token es válido (200 OK en el server), vamos a Home
          if (snapshot.hasData && snapshot.data == true) {
            return const HomeScreens();
          } else {
            // Si el token ha caducado o no existe, limpiamos y vamos a Login
            // Hacemos el logout para asegurar que no queden datos corruptos
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
