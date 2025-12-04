import 'dart:typed_data';
import 'dart:convert';

/// Modelo de Cliente para sincronizar con el backend.
/// El campo `imagen` se maneja como Uint8List (bytes) para mapear un BLOB en BD.
class Cliente {
  final int id;
  final String username;
  final String nombre;
  final String email;
  final int telefono;
  final String contrasenya;
  final bool estado;
  final String role;
  final String alergenos;
  final String direccion;
  final String observacion;
  final Uint8List? imagen;   // Imagen en binario (BLOB en BD)

  Cliente({
    required this.id,
    required this.username,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.contrasenya,
    required this.estado,
    required this.role,
    required this.alergenos,
    required this.direccion,
    required this.observacion,
    this.imagen,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? 0,
      contrasenya: json['contrasenya'] ?? '',
      estado: json['estado'] ?? false,
      role: json['role'] ?? '',
      alergenos: json['alergenos'] ?? '',
      direccion: json['direccion'] ?? '',
      observacion: json['observacion'] ?? '',
      imagen: json['imagen'] != null && (json['imagen'] as String).isNotEmpty
          ? base64Decode(json['imagen'])
          : null,
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
      "imagen": imagen != null ? base64Encode(imagen!) : "",
    };
  }
}
