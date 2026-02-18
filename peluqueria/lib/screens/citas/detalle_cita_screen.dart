import 'dart:convert'; // Necesario para base64Decode
import 'package:flutter/material.dart';
import 'package:peluqueria/widget/texto_automatico.dart';

class DetalleCitaScreen extends StatefulWidget {
  final dynamic cita;
  const DetalleCitaScreen({super.key, required this.cita});

  @override
  State<DetalleCitaScreen> createState() => _DetalleCitaScreenState();
}

class _DetalleCitaScreenState extends State<DetalleCitaScreen> {
  final Color naranjaLogo = const Color(0xFFFF6B00);
  final Color negroSuave = const Color(0xFF2D2D2D);

  @override
  Widget build(BuildContext context) {
    // Extraemos la valoración del objeto cita
    final val = widget.cita['valoracion'];
    final bool estaValorada = val != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: negroSuave, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const TextoAutomatico("DETALLE DE LA RESERVA", 
          style: TextStyle(color: Color(0xFF2D2D2D), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Información de la cita"),
              const SizedBox(height: 20),
              _buildReadOnlyField("FECHA", widget.cita['fecha'], Icons.calendar_today),
              const SizedBox(height: 15),
              _buildReadOnlyField("HORA", "${widget.cita['horaInicio'].substring(0, 5)} h", Icons.access_time),
              const SizedBox(height: 15),
              _buildReadOnlyField("ESTADO", widget.cita['estado'] ?? "CONFIRMADO", Icons.info_outline),

              // --- SECCIÓN DE VALORACIÓN ---
              if (estaValorada) ...[
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 20),
                _buildSectionTitle("Tu valoración"),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Puntuación General destacada
                      _buildStarRowDetailed("Puntuación General", val['puntuacion'], isMain: true),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(),
                      ),
                      
                      // Desglose de estrellas por categoría
                      _buildStarRowDetailed("Trato personal", val['trato']),
                      _buildStarRowDetailed("Desarrollo del servicio", val['desarrollo']),
                      _buildStarRowDetailed("Claridad en la comunicación", val['comunicacion']),
                      _buildStarRowDetailed("Limpieza y organización", val['organizacion']),
                      
                      const SizedBox(height: 20),
                      const TextoAutomatico("COMENTARIO", 
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 5),
                      TextoAutomatico(
                        val['comentario'] ?? "Sin comentario",
                        style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87, fontSize: 14),
                      ),

                      // --- VISUALIZACIÓN DE IMAGEN (BASE64) ---
                      if (val['imagen'] != null && val['imagen'].toString().isNotEmpty) ...[
                        const SizedBox(height: 25),
                        const TextoAutomatico("FOTO DEL RESULTADO", 
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            base64Decode(val['imagen']), // Decodifica el string Base64 del backend
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 100,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ] else if (widget.cita['estado'] == "COMPLETADO") ...[
                const SizedBox(height: 40),
                const Center(
                  child: TextoAutomatico("Cita pendiente de valoración", 
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Widget para filas de estrellas detalladas
  Widget _buildStarRowDetailed(String label, dynamic score, {bool isMain = false}) {
    int finalScore = score ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextoAutomatico(label, 
              style: TextStyle(
                fontSize: isMain ? 14 : 12, 
                fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
                color: isMain ? negroSuave : Colors.black87
              )),
          ),
          Row(
            children: List.generate(5, (index) => Icon(
              index < finalScore ? Icons.star : Icons.star_border,
              color: naranjaLogo,
              size: isMain ? 20 : 16,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return TextoAutomatico(title, style: TextStyle(color: negroSuave, fontSize: 18, fontWeight: FontWeight.w900));
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: naranjaLogo.withOpacity(0.7), size: 20),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextoAutomatico(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              TextoAutomatico(value, style: TextStyle(fontSize: 15, color: negroSuave, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}