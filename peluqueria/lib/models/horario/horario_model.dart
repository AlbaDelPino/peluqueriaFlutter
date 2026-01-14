import 'dart:convert';
import '../servicios/servicio_model.dart'; // Asegúrate de tener este import
import '../grupo/grupo_model.dart';    // Y este

class HorarioSemanal {
  final int id;
  final String diaSemana;
  final String horaInicio;
  final String horaFin;
  final int plazas;
  final Servicio? servicio;
  final dynamic grupo; // Puedes usar un modelo Grupo si lo tienes

  HorarioSemanal({
    required this.id,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.plazas,
    this.servicio,
    this.grupo,
  });
// horario_model.dart

factory HorarioSemanal.fromJson(Map<String, dynamic> json) {
  return HorarioSemanal(
    id: json['id'] ?? 0,
    diaSemana: json['diaSemana'] ?? '',
    horaInicio: json['horaInicio'] ?? '',
    horaFin: json['horaFin'] ?? '',
    plazas: json['plazas'] ?? 0,
    // LA SOLUCIÓN ESTÁ AQUÍ:
    // No pases el json['grupo'] directamente, conviértelo usando Grupo.fromJson
    grupo: json['grupo'] != null ? Grupo.fromJson(json['grupo']) : null,
  );
}
}