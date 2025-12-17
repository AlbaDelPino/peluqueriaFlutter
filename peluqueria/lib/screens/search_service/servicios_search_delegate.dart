import 'package:flutter/material.dart';
import '../../providers/service_provider.dart';
import '../calendar/service_detail_screen.dart'; // 👈 importa la pantalla de detalle

class ServiciosSearchDelegate extends SearchDelegate {
  final ServiceProvider provider;
  static const primary = Color(0xFFFF8B00);

  ServiciosSearchDelegate(this.provider);

  IconData _iconForTipo(int idTipo) {
    switch (idTipo) {
      case 1: return Icons.content_cut;
      case 2: return Icons.clean_hands;
      case 3: return Icons.spa;
      case 4: return Icons.remove_red_eye;
      case 5: return Icons.face;
      case 6: return Icons.self_improvement;
      case 7: return Icons.airline_seat_flat;
      case 8: return Icons.brush;
      case 9: return Icons.edit;
      default: return Icons.miscellaneous_services;
    }
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: primary),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: primary),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final resultados = provider.buscarServicios(query);
    if (resultados.isEmpty) {
      return const Center(
        child: Text("No se encontraron servicios",
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }
    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: resultados.length,
        itemBuilder: (_, i) {
          final servicio = resultados[i];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Icon(
                _iconForTipo(servicio.tipoServicio.id),
                color: primary,
                size: 28,
              ),
              title: Text(
                servicio.nombre,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                servicio.descripcion,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              trailing: Text(
                "${servicio.precio} €",
                style: const TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceDetailScreen(servicio: servicio),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final sugerencias = provider.buscarServicios(query);
    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sugerencias.length,
        itemBuilder: (_, i) {
          final servicio = sugerencias[i];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: Icon(
                _iconForTipo(servicio.tipoServicio.id),
                color: primary,
              ),
              title: Text(
                servicio.nombre,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                servicio.descripcion,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceDetailScreen(servicio: servicio),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
