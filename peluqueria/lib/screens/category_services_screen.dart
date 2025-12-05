import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider.dart';
import 'service_detail_screen.dart'; // 👈 importa la pantalla de detalle

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
            backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFFFF8B00),
        title: Text(
          nombreCategoria,
          style: const TextStyle(
            color: Colors.white, // 👈 título en blanco
            fontSize: 20,        // 👈 tamaño normal, sin negrita
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // 👈 flecha (back button) en blanco
        ),
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
                    leading: const Icon(
                      Icons.miscellaneous_services,
                      color: Color(0xFFFF8B00),
                    ),
                    title: Text(
                      servicio.nombre,
                      style: const TextStyle(
                        color: Colors.black, // 👈 texto normal
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(servicio.descripcion),
                    trailing: Text("${servicio.precio} €"),
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
