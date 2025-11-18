import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter/services.dart';
=======
import 'package:flutter/services.dart'; // necesario para bloquear orientación
>>>>>>> 622ce709b8c2e8138a34ac2c7d98fe8eb67c3302
import 'package:provider/provider.dart';

import 'providers/service_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const Color brandColor = Color(0xFFFF8B00);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServiceProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Centro de Belleza',
        theme: ThemeData(
          colorSchemeSeed: brandColor,
          useMaterial3: true,
        ),
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
