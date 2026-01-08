import 'dart:typed_data';
import 'dart:convert';

class ClienteModel {
  final int id;
  final String username;
  final String nombre;
  final String email;
  final int telefono;
  final String contrasenya;
  final bool estado;
  final String role;
  final String? alergenos;
  final String direccion;
  final String observacion;
  final String
  imagen; // 👈 Mantenlo como String (Base64) para facilitar el envío/recepción

  ClienteModel({
    required this.id,
    required this.username,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.contrasenya,
    required this.estado,
    required this.role,
    this.alergenos,
    required this.direccion,
    required this.observacion,
    this.imagen = "",
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      // Seguridad: si el teléfono viene como String del servidor, lo convierte a int
      telefono: json['telefono'] is int
          ? json['telefono']
          : int.tryParse(json['telefono'].toString()) ?? 0,
      contrasenya: json['contrasenya'] ?? '',
      estado: json['estado'] ?? false,
      role: json['role'] ?? '',
      alergenos: json['alergenos'] ?? '',
      direccion: json['direccion'] ?? '',
      observacion: json['observacion'] ?? '',
      // Lo guardamos directamente como el String Base64 que viene del JSON
      imagen: json['imagen']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "nombre": nombre,
      "email": email,
      "telefono": telefono,
      "contrasenya": contrasenya,
      "estado": estado,
      "role": role,
      "alergenos": alergenos,
      "direccion": direccion,
      "observacion": observacion,
      "imagen": imagen, // Ya es un String Base64
    };
  }

  // 💡 Útil para mostrar la imagen en la UI fácilmente
  Uint8List? get imagenBytes => imagen.isNotEmpty ? base64Decode(imagen) : null;
}
