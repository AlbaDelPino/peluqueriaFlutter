import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider.dart';

class CategoryServicesScreen extends StatelessWidget {
  final int idTipo;
  final String nombreCategoria;

  const CategoryServicesScreen({
    super.key,
    required this.idTipo,
    required this.nombreCategoria,
  });

  @override
  Widget build(BuildContext context) {
    final servicios = context.watch<ServiceProvider>().getServiciosPorTipo(idTipo);
    const primary = Color(0xFFFF8B00);

    return Scaffold(
      appBar: AppBar(title: Text(nombreCategoria), backgroundColor: primary),
      body: servicios.isEmpty
          ? const Center(child: Text('No hay servicios en esta categoría'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: servicios.length,
              itemBuilder: (ctx, i) {
                final s = servicios[i];
                final precio = (s['precio'] as num).toStringAsFixed(2);
                final duracion = s['duracion'];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      child: Icon(_iconForTipo(s['id_tipo'] as int), color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(s['nombre'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(s['descripcion'] as String),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$precio €', style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('${duracion} h', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    onTap: () {
                      // Acción al pulsar el servicio
                    },
                  ),
                );
              },
            ),
    );
  }

  IconData _iconForTipo(int idTipo) {
    switch (idTipo) {
      case 1:
        return Icons.content_cut;
      case 2:
        return Icons.clean_hands;
      case 3:
        return Icons.spa;
      case 4:
        return Icons.remove_red_eye;
      case 5:
        return Icons.face;
      case 6:
        return Icons.self_improvement;
      case 7:
        return Icons.airline_seat_flat;
      case 8:
        return Icons.brush;
      case 9:
        return Icons.edit;
      default:
        return Icons.miscellaneous_services;
    }
  }
}
