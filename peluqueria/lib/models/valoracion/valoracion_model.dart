class Valoracion {
  final int? id;
  final String comentario;
  final int puntuacion;
  final int trato;
  final int desarrollo;
  final int comunicacion;
  final int organizacion;
  final String? imagen;
  final int? citaId;

  Valoracion({
    this.id,
    required this.comentario,
    required this.puntuacion,
    required this.trato,
    required this.desarrollo,
    required this.comunicacion,
    required this.organizacion,
    this.imagen,
    this.citaId,
  });

  // Para recibir datos del servidor
  factory Valoracion.fromJson(Map<String, dynamic> json) => Valoracion(
        id: json["id"],
        comentario: json["comentario"] ?? "",
        puntuacion: json["puntuacion"] ?? 0,
        trato: json["trato"] ?? 0,
        desarrollo: json["desarrollo"] ?? 0,
        comunicacion: json["comunicacion"] ?? 0,
        organizacion: json["organizacion"] ?? 0,
        imagen: json["imagen"],
        citaId: json["cita"] != null ? json["cita"]["id"] : null,
      );

  // Para enviar datos al servidor (POST)
  Map<String, dynamic> toJson(int idCita) => {
        "comentario": comentario,
        "puntuacion": puntuacion,
        "trato": trato,
        "desarrollo": desarrollo,
        "comunicacion": comunicacion,
        "organizacion": organizacion,
        "imagen": imagen,
        "cita": {"id": idCita} // Enlazamos con la cita
      };
}