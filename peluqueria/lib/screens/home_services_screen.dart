import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider.dart';
import 'category_services_screen.dart';
import 'servicios_search_delegate.dart';

class HomeServicesScreen extends StatefulWidget {
  const HomeServicesScreen({super.key});

  @override
  State<HomeServicesScreen> createState() => _HomeServicesScreenState();
}

class _HomeServicesScreenState extends State<HomeServicesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<ServiceProvider>();
      provider.cargarTiposServicio();
      provider.cargarServicios();
    });
  }

  static const primary = Color(0xFFFF8B00);

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
  Widget build(BuildContext context) {
    final tipos = context.watch<ServiceProvider>().tiposServicio;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary,
        title: const Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: Text(
            'Servicios por categoría',
            style: TextStyle(color: Colors.white),
          ),
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
      body: tipos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: tipos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final tipo = tipos[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10), // 👈 espacio arriba y abajo del bloque
                    padding: const EdgeInsets.symmetric(vertical: 12), // 👈 espacio interno del contenido
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      leading: Icon(
                        _iconForTipo(tipo.id),
                        color: primary,
                        size: 32,
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(
                          tipo.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryServicesScreen(
                              idTipo: tipo.id,
                              nombreCategoria: tipo.nombre,
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
