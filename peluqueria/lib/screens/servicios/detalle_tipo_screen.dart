import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/servicios/servicio_model.dart';
import '../calendario/calendario_screen.dart';
import '../../widget/texto_automatico.dart';

class DetalleTipoScreen extends StatefulWidget {
  final String titulo;
  final List<Servicio> servicios;
  final Set<int> idsFavoritos;
  final Function(Servicio, bool) onToggle;

  const DetalleTipoScreen({
    super.key,
    required this.titulo,
    required this.servicios,
    required this.idsFavoritos,
    required this.onToggle,
  });

  @override
  State<DetalleTipoScreen> createState() => _DetalleTipoScreenState();
}

class _DetalleTipoScreenState extends State<DetalleTipoScreen> {
  // Color corporativo unificado con el calendario
  final Color naranjaLogo = const Color(0xFFFF6B00);

  void _handleLocalTap(Servicio s) {
    final bool yaEraFav = widget.idsFavoritos.contains(s.idServicio);
    final bool nuevoEstado = !yaEraFav;

    setState(() {
      if (nuevoEstado) {
        widget.idsFavoritos.add(s.idServicio);
      } else {
        widget.idsFavoritos.remove(s.idServicio);
      }
    });

    widget.onToggle(s, nuevoEstado);
  }

  @override
  Widget build(BuildContext context) {
    // Detectamos idioma para posibles textos dinámicos
    final String languageCode = Localizations.localeOf(context).languageCode;
    final bool isEn = languageCode == 'en';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: TextoAutomatico(
          widget.titulo.toUpperCase(),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: ListView.builder(
        // Añadimos SafeArea manual con el padding inferior
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 30),
        itemCount: widget.servicios.length,
        itemBuilder: (context, index) {
          final s = widget.servicios[index];
          final bool esFav = widget.idsFavoritos.contains(s.idServicio);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20), // Bordes más redondeados
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextoAutomatico(
                        s.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextoAutomatico(
                        "${s.precio}€ ${isEn ? '(DONATION)' : '(DONACIÓN)'}",
                        style: TextStyle(
                          color: naranjaLogo,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Botón de Favorito
                IconButton(
                  onPressed: () => _handleLocalTap(s),
                  icon: Icon(
                    esFav ? Icons.favorite : Icons.favorite_border,
                    color: esFav ? naranjaLogo : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(width: 8),
                // Botón Reservar
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CalendarioScreen(servicio: s),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: TextoAutomatico(
                    isEn ? "Book" : "Reservar",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}