import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/service_provider.dart';
import '../../widgets/widget.dart'; // 👈 aquí exportas CategoryCard
import 'category_services_screen.dart';
import '../search_service/servicios_search_delegate.dart';

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
      body: SafeArea(
        child: tipos.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 20, // 👈 espacio dinámico
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // catálogo en dos columnas
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9, // 👈 tarjetas un poco más altas
                ),
                itemCount: tipos.length,
                itemBuilder: (ctx, i) {
                  final tipo = tipos[i];
                  return CategoryCard(
                    nombre: tipo.nombre,
                    icon: _iconForTipo(tipo.id),
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
                  );
                },
              ),
      ),
    );
  }
}
