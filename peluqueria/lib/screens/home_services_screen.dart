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
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: primary,
        centerTitle: true,
        title: const Text(
          'Servicios por categoría',
          style: TextStyle(color: Colors.white, fontSize: 18),
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
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 👈 dos columnas tipo catálogo
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: tipos.length,
              itemBuilder: (ctx, i) {
                final tipo = tipos[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_iconForTipo(tipo.id), color: primary, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          tipo.nombre,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
