import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/ServicioImagen/servicio_imagen_model.dart';

class GaleriaServiciosScreen extends StatelessWidget {
  final int? servicioId;
  final String? nombreServicio;

  const GaleriaServiciosScreen({super.key, this.servicioId, this.nombreServicio});

  Future<List<ServicioImagen>> fetchImagenes(int? id) async {
    // Si no hay ID, pedimos todas las imágenes para la galería general
    String urlFinal = (id == null) 
        ? 'http://192.168.7.13:8082/api/imagenes' 
        : 'http://192.168.7.13:8082/api/imagenes/servicio/$id';

    final url = Uri.parse(urlFinal);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => ServicioImagen.fromJson(item)).toList();
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
      backgroundColor: Colors.white, // FONDO BLANCO
      appBar: AppBar(
        title: Text(
          nombreServicio ?? "Nuestros Trabajos", 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF6B00), // Naranja Bernat
        elevation: 0,
      ),
      body: FutureBuilder<List<ServicioImagen>>(
        future: fetchImagenes(servicioId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay fotos disponibles."));
          }

          // --- DISEÑO DE CARRUSEL (PageView) ---
          return PageView.builder(
            itemCount: snapshot.data!.length,
            controller: PageController(viewportFraction: 0.88),
            itemBuilder: (context, index) {
              final img = snapshot.data![index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // 1. LA IMAGEN DE FONDO
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.memory(
                          base64Decode(img.datos),
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                        ),
                      ),
                      
                      // 2. GRADIENTE PARA MEJORAR LECTURA DEL TEXTO
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(25),
                              bottomRight: Radius.circular(25),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8), // Negro suave
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // 3. NOMBRE DEL SERVICIO ASOCIADO
                      Positioned(
                        bottom: 30,
                        left: 20,
                        right: 20,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              img.nombreServicio.toUpperCase(), // VIENE DEL MODELO
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: Colors.black,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            // Línea decorativa naranja
                            Container(
                              height: 4,
                              width: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B00),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}