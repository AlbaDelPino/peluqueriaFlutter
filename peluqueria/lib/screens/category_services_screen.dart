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
    final servicios = context
        .watch<ServiceProvider>()
        .servicios
        .where((s) => s.tipoServicio.id == idTipo)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(nombreCategoria),
        backgroundColor: const Color(0xFFFF8B00),
      ),
      body: servicios.isEmpty
          ? const Center(child: Text("No hay servicios disponibles"))
          : ListView.builder(
              itemCount: servicios.length,
              itemBuilder: (_, i) {
                final servicio = servicios[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.miscellaneous_services, color: Color(0xFFFF8B00)),
                    title: Text(servicio.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(servicio.descripcion),
                    trailing: Text("${servicio.precio} €"),
                  ),
                );
              },
            ),
    );
  }
}
