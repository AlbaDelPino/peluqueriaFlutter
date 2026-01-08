import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'shared_prefs/user_preferences.dart';

<<<<<<< Updated upstream
import 'shared_prefs/user_preferences.dart';
import 'providers/auth_provider.dart';
import 'providers/service_provider.dart';
import 'providers/cliente_provider.dart';

=======
import 'providers/auth_provider.dart';
import 'providers/service_provider.dart';
import 'providers/cliente_provider.dart'; // 👈 asegúrate de importar esto
>>>>>>> Stashed changes
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

<<<<<<< Updated upstream
  await initializeDateFormatting('es_ES', null);
// Fuerza la app a funcionar solo en orientacion vertical
=======
>>>>>>> Stashed changes
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

<<<<<<< Updated upstream
// incializa la claise de preferencias (SharePrefeences) para guardas datos persistentes 
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
        ChangeNotifierProvider(create: (_) => ClienteProvider()),
=======
        ChangeNotifierProvider(create: (_) => ClienteProvider()), // ✅ activado
>>>>>>> Stashed changes
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: brandColor,
          useMaterial3: true,
        ),
<<<<<<< Updated upstream
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
        ],
=======
>>>>>>> Stashed changes
        initialRoute: '/',
        routes: {
          '/': (_) => const LoginScreen(),
          '/signup': (_) => const SignUpScreen(),
<<<<<<< Updated upstream
          '/home': (_) => const MainNavigation(), // 👈 navegación principal
=======
          '/home': (_) => const MainNavigation(),
>>>>>>> Stashed changes
        },
      ),
    );
  }
}
