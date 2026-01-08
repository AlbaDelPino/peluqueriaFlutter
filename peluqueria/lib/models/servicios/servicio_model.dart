import 'tipo_servicio_model.dart';

class Servicio {
  final int idServicio;
  final String nombre;
  final String descripcion;
  final double precio;
  final int duracion;
  final TipoServicio tipoServicio; // <--- Usamos el modelo aquí

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
      idServicio: json['id_servicio'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: (json['precio'] as num).toDouble(),
      duracion: json['duracion'] ?? 0,
      // Usamos el factory del modelo TipoServicio
      tipoServicio: TipoServicio.fromJson(json['tipoServicio']),
    );
  }
}
