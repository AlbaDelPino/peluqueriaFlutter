import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart'; // 👈 necesario para el calendario

import 'package:provider/provider.dart';
import 'shared_prefs/user_preferences.dart';

import 'providers/auth_provider.dart';
import 'providers/service_provider.dart';
import 'providers/cliente_provider.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa datos de formato para español (requerido por TableCalendar)
  await initializeDateFormatting('es_ES', null);

  // Bloqueamos la orientación en vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializamos las preferencias de usuario
  final prefs = UserPreferences();
  await prefs.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const Color brandColor = Color(0xFFFF8B00);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => ClienteProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: brandColor,
          useMaterial3: true,
        ),
        // 🌍 Soporte de localización
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'), // 👈 Español
        ],
        initialRoute: '/',
        routes: {
          '/': (_) => const LoginScreen(),
          '/signup': (_) => const SignUpScreen(),
          '/home': (_) => const MainNavigation(),
        },
      ),
    );
  }
}
