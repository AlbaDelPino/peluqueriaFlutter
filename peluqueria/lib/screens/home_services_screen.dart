import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider.dart';
import 'category_services_screen.dart';
import 'servicios_search_delegate.dart';

class HomeServicesScreen extends StatelessWidget {
  const HomeServicesScreen({super.key});

  static const primary = Color(0xFFFF8B00);

  // 🔹 Función para asignar icono según idTipo
  IconData _iconForTipo(int idTipo) {
    switch (idTipo) {
      case 1:
        return Icons.content_cut;          // Corte
      case 2:
        return Icons.clean_hands;          // Lavado
      case 3:
        return Icons.spa;                  // Spa
      case 4:
        return Icons.remove_red_eye;       // Cejas / pestañas
      case 5:
        return Icons.face;                 // Facial
      case 6:
        return Icons.self_improvement;     // Relajación
      case 7:
        return Icons.airline_seat_flat;    // Masajes
      case 8:
        return Icons.brush;                // Color
      case 9:
        return Icons.edit;                 // Personalización
      default:
        return Icons.miscellaneous_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tipos = context.watch<ServiceProvider>().tiposServicio;

    return Scaffold(
      backgroundColor: Colors.white, // 👈 fondo blanco uniforme
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text(
          'Servicios por categoría',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              final provider = context.read<ServiceProvider>();
              showSearch(
                context: context,
                delegate: ServiciosSearchDelegate(provider),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: tipos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8), // 👈 separación entre tarjetas
        itemBuilder: (ctx, i) {
          final tipo = tipos[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: Icon(
                  _iconForTipo(tipo['id_tipo'] as int),
                  color: primary,
                  size: 32,
                ),
                title: Text(
                  tipo['nombre'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: tipo.containsKey('descripcion')
                    ? Text(tipo['descripcion'] as String)
                    : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryServicesScreen(
                        idTipo: tipo['id_tipo'] as int,
                        nombreCategoria: tipo['nombre'] as String,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
