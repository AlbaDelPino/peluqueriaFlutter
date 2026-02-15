import 'package:flutter/material.dart';
import 'package:peluqueria/widget/texto_automatico.dart';

class DetallesScreen extends StatelessWidget {
  final String nombreRecibido;

  // Constructor para recibir el nombre desde la Home
  DetallesScreen({required this.nombreRecibido});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "¡Bienvenido a la otra pantalla!",
              style: TextStyle(fontSize: 18),
            ),
            Text(
              nombreRecibido,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context), // Volver atrás
              child: Text("Volver a la Home"),
            ),
          ],
        ),
      ),
    );
  }
}
