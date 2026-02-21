import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; 
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'package:firebase_core/firebase_core.dart'; // Añadido
import 'package:peluqueria/services/user_preferences.dart';
import 'package:peluqueria/screens/login/login_screen.dart';
import 'package:peluqueria/screens/home_screens.dart';
import 'package:peluqueria/screens/login/signup_screen.dart';
import 'package:peluqueria/providers/locale_provider.dart'; 
import 'package:intl/date_symbol_data_local.dart';
import 'package:peluqueria/services/notification_service.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inicializar Firebase
  await Firebase.initializeApp(); 

  // 2. Inicializar nuestro servicio de notificaciones
  await NotificationService.init();

  // Bloquear orientación vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Cargamos los formatos de fecha
  await Future.wait([
    initializeDateFormatting('es', null),
    initializeDateFormatting('en', null),
  ]);

  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = UserPreferences();
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bernat Experience',
      locale: localeProvider.locale, 
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
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
              body: Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00))),
            );
          }
          return (snapshot.hasData && snapshot.data == true) 
              ? const HomeScreens() 
              : const LoginScreen();
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