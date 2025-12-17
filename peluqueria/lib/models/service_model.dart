

























































class TipoServicio {
  final int id;
  final String nombre;

  TipoServicio({
    required this.id,
    required this.nombre,
  });

  factory TipoServicio.fromJson(Map<String, dynamic> json) {
    return TipoServicio(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}

class Servicio {
  final int idServicio;
  final String nombre;
  final String descripcion;
  final double precio;
  final int duracion;
  final TipoServicio tipoServicio;

  Servicio({
    required this.idServicio,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.duracion,
    required this.tipoServicio,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      idServicio: json['id_servicio'],
      nombre: json['nombre'],
      descripcion: json['descripcion'] ?? '',
      precio: (json['precio'] as num).toDouble(),
      duracion: json['duracion'],
      tipoServicio: TipoServicio.fromJson(json['tipoServicio']),
    );
  }
}
