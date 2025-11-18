import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider.dart';

class HomeServicesScreen extends StatelessWidget {
  const HomeServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final categories = serviceProvider.services.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Servicios disponibles")),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (ctx, i) {
          final category = categories[i];
          final services = serviceProvider.services[category]!;

          return ExpansionTile(
            title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
            children: services.map((service) {
              return ListTile(
                title: Text(service.name),
                subtitle: Text("Duración: ${service.duration}"),
                trailing: Text("${service.price.toStringAsFixed(2)} €"),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
