import 'package:flutter/material.dart';
import '../providers/providers.dart';

class ServiciosSearchDelegate extends SearchDelegate {
  final ServiceProvider provider;

  ServiciosSearchDelegate(this.provider);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final resultados = provider.buscarServicios(query);
    return ListView.builder(
      itemCount: resultados.length,
      itemBuilder: (_, i) {
        final servicio = resultados[i];
        return ListTile(
          title: Text(servicio['nombre']),
          subtitle: Text(servicio['descripcion']),
          trailing: Text("${servicio['precio']} €"),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final sugerencias = provider.buscarServicios(query);
    return ListView.builder(
      itemCount: sugerencias.length,
      itemBuilder: (_, i) {
        final servicio = sugerencias[i];
        return ListTile(
          title: Text(servicio['nombre']),
          subtitle: Text(servicio['descripcion']),
        );
      },
    );
  }
}
