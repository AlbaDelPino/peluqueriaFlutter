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
  final String imagen;

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
    required this.imagen,
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
      imagen: json['imagen'] ?? '',
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
      "imagen": imagen,
    };
  }
}
