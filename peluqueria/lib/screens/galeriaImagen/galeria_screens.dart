import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/ServicioImagen/servicio_imagen_model.dart';
import '../../config/api_config.dart';
import 'package:peluqueria/widget/texto_automatico.dart';

class GaleriaServiciosScreen extends StatelessWidget {
  final int? servicioId;
  final String? nombreServicio;
  final Color negroSuave = const Color(0xFF2D2D2D);

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
  return Scaffold(
    // 1. Fondo principal blanco
    backgroundColor: Colors.white, 
    appBar: AppBar(
      title: TextoAutomatico(
        "NUESTRO TRABAJO",
        style: TextStyle(
          color: negroSuave,
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      // Cambiamos el icono a negro para que se vea sobre el fondo blanco
      iconTheme: IconThemeData(color: negroSuave),
    ),
    body: FutureBuilder<List<ServicioImagen>>(
      future: fetchImagenes(servicioId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
          );
        } else if (snapshot.hasError) {
          return Center(child: TextoAutomatico("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: TextoAutomatico("No hay fotos disponibles."));
        }

        final imagenes = snapshot.data!;

        return Column(
          children: [
            const SizedBox(height: 20),
            const TextoAutomatico(
              "Desliza para ver más",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Container(
                // 2. Forzamos blanco también en el contenedor del PageView
                color: Colors.white, 
                child: PageView.builder(
                  itemCount: imagenes.length,
                  controller: PageController(viewportFraction: 0.85),
                  itemBuilder: (context, index) {
                    final img = imagenes[index];

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          // 3. Sombra muy sutil negra para dar profundidad sobre el blanco
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(
                              base64Decode(img.datos),
                              fit: BoxFit.cover,
                            ),
                            // Gradiente para que el texto sea legible
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: const [0.7, 1.0],
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 30,
                              left: 20,
                              right: 20,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextoAutomatico(
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
            ),
            const SizedBox(height: 40),
          ],
        );
      },
    ),
  );
}
}