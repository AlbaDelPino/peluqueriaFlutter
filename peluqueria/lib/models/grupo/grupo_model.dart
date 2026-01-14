// grupo_model.dart

class Grupo {
  final int id;
  final String nombre;
  final String curso;
  final String turno;

  Grupo({required this.id, required this.nombre, required this.curso, required this.turno});

  factory Grupo.fromJson(Map<String, dynamic> json) {
    return Grupo(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      curso: json['curso'] ?? '',
      turno: json['turno'] ?? '', // Verifica que en Java se llame "turno"
    );
  }
}