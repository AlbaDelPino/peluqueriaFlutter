import 'package:flutter/material.dart';
import 'package:peluqueria/screens/detalles_screen.dart';

class InicioContenido extends StatefulWidget {
  @override
  _InicioContenidoState createState() => _InicioContenidoState();
}

class _InicioContenidoState extends State<InicioContenido> {
  final TextEditingController micontrolador = TextEditingController();
  String mensaje = "Esperando pulsación...";
  String bienvenida = "";
  bool mostrarSaludo = false;

  @override
  Widget build(BuildContext context) {
    // 1. La App (Configuración global)
    return Scaffold(
      // 2. La Pantalla (Estructura visual)
      // appBar: AppBar(
      //   // 3. La Barra de arriba
      //   title: Text('home Screen'),
      //   backgroundColor: Colors.blue,
      // ),

      // drawer: MenuLateral(),
      //1. Añadimos scroll para que el teclado no rompa la pantalla
      body: SingleChildScrollView(
        // 4. El centro del cuerpo
        child: Padding(
          padding: const EdgeInsets.all(16.6),
          // 5. Una columna (organiza verticalmente)
          child: Column(
            children: [
              // 6. Lista de varios elementos:
              Text(mensaje, style: TextStyle(fontSize: 20)),
              Icon(Icons.access_alarm, size: 50, color: Colors.green),
              Row(
                // Una fila dentro de la columna
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Elemento en fila 1 - '),
                  Text('Elemento en fila 2'),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // CENTRA los botones
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetallesScreen(
                            nombreRecibido: micontrolador.text,
                          ),
                        ),
                      );
                      setState(() {
                        mensaje = "presionado!";
                        mostrarSaludo = true;
                      });
                    },
                    child: Text('bton'),
                  ),

                  SizedBox(width: 50),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Limpiar'),
                            content: Text("limpaido correcto"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('cerrar'),
                              ),
                            ],
                          );
                        },
                      );
                      // 3. ¡IMPORTANTE! Usamos setState para actualizar la pantalla
                      setState(() {
                        mensaje = "¡Limpardo correctamnete!";
                        mostrarSaludo = false;
                      });
                    },
                    child: Text('limpiar'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: micontrolador,
                decoration: InputDecoration(
                  labelText: 'Escribe tu nombre',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              if (mostrarSaludo && micontrolador.text.isNotEmpty)
                Text(
                  'hola , ${micontrolador.text}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),

              SizedBox(height: 20),
              Image.network(
                mostrarSaludo
                    ? 'https://img.icons8.com/clouds/200/handshake.png' // Imagen de saludo
                    : 'https://img.icons8.com/clouds/200/user.png', // Imagen de espera
                height: 150,
              ),
            ],
          ),
          // Cierre de children
        ), // Cierre de Column
      ),
    ); // Cierre de Center
    // Cierre de Scaffold
    // Cierre de MaterialApp
  }
}
