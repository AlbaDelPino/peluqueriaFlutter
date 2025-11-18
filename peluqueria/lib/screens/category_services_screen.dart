import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider.dart';

class CategoryServicesScreen extends StatelessWidget {
  final String category;

  const CategoryServicesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final services = serviceProvider.services[category] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: ListView.builder(
        itemCount: services.length,
        itemBuilder: (ctx, i) {
          final service = services[i];
          return Card(
            child: ListTile(
              title: Text(service["name"]),
              subtitle: Text("Duración: ${service["duration"]}"),
              trailing: Text("${service["price"].toStringAsFixed(2)} €"),
            ),
          );
        },
      ),
    );
  }
}
