class ServicioImagen {
  final int id;
  final String datos;
  final String nombreServicio; // Aquí guardaremos el nombre real

  ServicioImagen({
    required this.id, 
    required this.datos, 
    required this.nombreServicio
  });

  factory ServicioImagen.fromJson(Map<String, dynamic> json) {
    return ServicioImagen(
      id: json['id'],
      datos: json['datos'],
      // ENTRAMOS AL MAPA 'servicio' Y LUEGO AL CAMPO 'nombre'
      nombreServicio: (json['servicio'] != null && json['servicio']['nombre'] != null)
          ? json['servicio']['nombre'] 
          : "Servicio Bernat",
    );
  }
}