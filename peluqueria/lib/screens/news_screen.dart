import 'package:flutter/material.dart';
import 'profile_screen.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF8B00);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias'),
        backgroundColor: primary,
        
      ),
      body: const Center(
        child: Text('Aquí irán las noticias'),
      ),
    );
  }
}
