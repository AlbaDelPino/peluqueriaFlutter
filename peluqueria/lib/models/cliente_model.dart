<<<<<<< Updated upstream
<<<<<<< Updated upstream
import 'dart:typed_data';//datos binarios
import 'dart:convert';//converson de cadena y binario

/// Modelo de Cliente para sincronizar con el backend.
//clase cCliente
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
<<<<<<< Updated upstream
  final Uint8List? imagen;   // Imagen en binario (BLOB en BD)

//constructor
=======
  final String imagen;

>>>>>>> Stashed changes
=======
  final String imagen;

>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
<<<<<<< Updated upstream
    this.imagen,
  });

//crear un objeto cliente a aprtir de un JSON
=======
    required this.imagen,
  });

>>>>>>> Stashed changes
=======
    required this.imagen,
  });

>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
<<<<<<< Updated upstream
      imagen: json['imagen'] != null && (json['imagen'] as String).isNotEmpty
          ? base64Decode(json['imagen'])
          : null,
    );
  }

//convierte el objeto Cliente en un mapa JSON para enviarlo al backend
=======
=======
>>>>>>> Stashed changes
      imagen: json['imagen'] ?? '',
    );
  }

<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
<<<<<<< Updated upstream
      "imagen": imagen != null ? base64Encode(imagen!) : "",
=======
      "imagen": imagen,
>>>>>>> Stashed changes
=======
      "imagen": imagen,
>>>>>>> Stashed changes
    };
  }
}
