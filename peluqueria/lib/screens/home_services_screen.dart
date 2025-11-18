import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider.dart';
import 'category_services_screen.dart';

class HomeServicesScreen extends StatelessWidget {
  const HomeServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tipos = context.watch<ServiceProvider>().tiposServicio;

    return Scaffold(
      appBar: AppBar(title: const Text('Servicios por categoría')),
      body: ListView.separated(
        itemCount: tipos.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (ctx, i) {
          final tipo = tipos[i];
          return ListTile(
            title: Text(tipo['nombre'] as String),
            subtitle: tipo.containsKey('descripcion') ? Text(tipo['descripcion'] as String) : null,
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
          );
        },
      ),
    );
  }
}
