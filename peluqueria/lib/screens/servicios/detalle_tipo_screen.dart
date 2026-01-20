import 'package:flutter/material.dart';
import '../../models/servicios/servicio_model.dart';
import '../calendario/calendario_screen.dart';

class DetalleTipoScreen extends StatefulWidget {
  final String titulo;
  final List<Servicio> servicios;
  final Set<int> idsFavoritos;
  final Function(Servicio, bool)
  onToggle; // Enviamos el servicio y el nuevo estado

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
  void _handleLocalTap(Servicio s) {
    // 1. Determinamos el nuevo estado ANTES de cambiarlo
    final bool yaEraFav = widget.idsFavoritos.contains(s.idServicio);
    final bool nuevoEstado = !yaEraFav;

    // 2. Actualizamos la interfaz LOCAL de inmediato
    setState(() {
      if (nuevoEstado) {
        widget.idsFavoritos.add(s.idServicio);
      } else {
        widget.idsFavoritos.remove(s.idServicio);
      }
    });

    // 3. Notificamos al padre para que hable con el servidor
    widget.onToggle(s, nuevoEstado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          widget.titulo,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: widget.servicios.length,
        itemBuilder: (context, index) {
          final s = widget.servicios[index];
          final bool esFav = widget.idsFavoritos.contains(s.idServicio);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        "${s.precio}€",
                        style: const TextStyle(
                          color: Color(0xFFFF6B00),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _handleLocalTap(s),
                  icon: Icon(
                    esFav ? Icons.favorite : Icons.favorite_border,
                    color: esFav
                        ? const Color(0xFFFF6B00)
                        : Colors.grey.shade400,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CalendarioScreen(servicio: s),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Reservar",
                    style: TextStyle(color: Colors.white),
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
