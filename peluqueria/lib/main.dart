import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // necesario para bloquear orientación
import 'package:provider/provider.dart';
import 'providers/service_provider.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bloquear solo en vertical (portrait)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServiceProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Centro de Belleza',
        theme: ThemeData(primarySwatch: Colors.pink),
        home: const MainNavigation(),
      ),
    );
  }
}
