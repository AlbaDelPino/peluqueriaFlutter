class TipoServicio {
  final int id;
  final String nombre;

  TipoServicio({required this.id, required this.nombre});

  // Para convertir el JSON de la API a objeto Dart
  factory TipoServicio.fromJson(Map<String, dynamic> json) {
    return TipoServicio(id: json['id'] ?? 0, nombre: json['nombre'] ?? '');
  }
}
