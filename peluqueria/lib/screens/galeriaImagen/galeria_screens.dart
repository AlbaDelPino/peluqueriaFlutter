import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/ServicioImagen/servicio_imagen_model.dart';
import '../../config/api_config.dart';

class GaleriaServiciosScreen extends StatelessWidget {
  final int? servicioId;
  final String? nombreServicio;

  const GaleriaServiciosScreen({
    super.key,
    this.servicioId,
    this.nombreServicio,
  });

  Future<List<ServicioImagen>> fetchImagenes(int? id) async {
    final String urlFinal = (id == null)
        ? ApiConfig.todasImagenesUrl
        : ApiConfig.imagenesPorServicio(id);
    final url = Uri.parse(urlFinal);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => ServicioImagen.fromJson(item)).toList();
      } else if (response.statusCode == 204) {
        return [];
      } else {
        throw Exception("Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error de red: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tamaño de la pantalla para ajustar proporciones
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F5F5,
      ), // Gris muy claro de fondo para resaltar las tarjetas
      appBar: AppBar(
        title: Text(
          nombreServicio ?? "Nuestros Trabajos",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF6B00),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<ServicioImagen>>(
        future: fetchImagenes(servicioId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay fotos disponibles."));
          }

          final imagenes = snapshot.data!;

          return Column(
            children: [
              const SizedBox(height: 20),
              // Texto indicativo
              const Text(
                "Desliza para ver más",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Contenedor principal del carrusel
              Expanded(
                child: PageView.builder(
                  itemCount: imagenes.length,
                  // viewportFraction 0.85 permite ver un poco de la siguiente imagen
                  controller: PageController(viewportFraction: 0.85),
                  itemBuilder: (context, index) {
                    final img = imagenes[index];

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      // Margen para separar las imágenes entre sí y de los bordes
                      margin: const EdgeInsets.symmetric(
                        vertical: 40, // Espacio arriba y abajo
                        horizontal: 10, // Espacio entre tarjetas
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // 1. Imagen optimizada
                            Image.memory(
                              base64Decode(img.datos),
                              fit: BoxFit.cover,
                            ),

                            // 2. Gradiente inferior más sutil
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: const [0.6, 1.0],
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.85),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // 3. Información del servicio
                            Positioned(
                              bottom: 30,
                              left: 20,
                              right: 20,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    img.nombreServicio.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    height: 3,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6B00),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}
