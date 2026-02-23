import 'dart:convert';

class Cita {
  final int idCita;
  final DateTime fecha;
  final String horaInicio;
  final String nombreServicio;
  final String estado;
  final int idCliente;

  Cita({
    required this.idCita,
    required this.fecha,
    required this.horaInicio,
    required this.nombreServicio,
    required this.estado,
    required this.idCliente,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    // 1. Extraer nombre del servicio desde la relación anidada en Java:
    // cita.horario.servicio.nombre
    String servicioNombre = 'Servicio';
    if (json['horario'] != null && 
        json['horario']['servicio'] != null && 
        json['horario']['servicio']['nombre'] != null) {
      servicioNombre = json['horario']['servicio']['nombre'];
    }

    // 2. Parseo de Fecha (viniendo de LocalDate de Java)
    // Java LocalDate suele venir como "2026-02-23"
    DateTime fechaParseada;
    try {
      fechaParseada = DateTime.parse(json['fecha']);
    } catch (e) {
      fechaParseada = DateTime.now();
    }

    return Cita(
      idCita: json['id'] ?? 0,
      fecha: fechaParseada,
      // LocalTime de Java suele venir como "10:30:00"
      horaInicio: json['horaInicio'] ?? '00:00:00',
      nombreServicio: servicioNombre,
      estado: json['estado'] ?? 'CONFIRMADO',
      idCliente: (json['cliente'] != null) ? (json['cliente']['id'] ?? 0) : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": idCita,
    "fecha": "${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}",
    "horaInicio": horaInicio,
    "estado": estado,
  };
}