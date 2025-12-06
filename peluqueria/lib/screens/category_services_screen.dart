import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider.dart';
import 'service_detail_screen.dart';

class CategoryServicesScreen extends StatelessWidget {
  final int idTipo;
  final String nombreCategoria;

  const CategoryServicesScreen({
    super.key,
    required this.idTipo,
    required this.nombreCategoria,
  });

// obtiene los servicios del tipo de servicio selecionado en home_services_screen
  @override
  Widget build(BuildContext context) {
    final servicios = context
        .watch<ServiceProvider>()
        .servicios
        .where((s) => s.tipoServicio.id == idTipo)
        .toList();
      

    const primary = Color(0xFFFF8B00);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
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
              padding: const EdgeInsets.all(16),
              itemCount: servicios.length,
              itemBuilder: (_, i) {
                final servicio = servicios[i];
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ServiceDetailScreen(servicio: servicio),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            servicio.nombre,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            servicio.descripcion,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              "${servicio.precio} €",
                              style: const TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
     ),
    );
  }
}
