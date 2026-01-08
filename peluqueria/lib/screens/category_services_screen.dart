import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider.dart';
<<<<<<< Updated upstream
<<<<<<< Updated upstream
import '../widgets/widget.dart'; // 👈 importa tus widgets reutilizables
import 'service_detail_screen.dart';
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
<<<<<<< Updated upstream

    const primary = Color(0xFFFF8B00);
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
<<<<<<< Updated upstream
<<<<<<< Updated upstream
        backgroundColor: primary,
        centerTitle: true,
        title: Text(
          nombreCategoria,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: servicios.isEmpty
            ? const Center(
                child: Text(
                  "No hay servicios disponibles",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 20, // 👈 espacio dinámico
                ),
                itemCount: servicios.length,
                itemBuilder: (_, i) {
                  final servicio = servicios[i];
                  return ServiceCard(
                    servicio: servicio,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ServiceDetailScreen(servicio: servicio),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
=======
=======
>>>>>>> Stashed changes
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
>>>>>>> Stashed changes
    );
  }
}
