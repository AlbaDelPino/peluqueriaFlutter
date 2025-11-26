import 'package:flutter/material.dart';

class ServiceProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _tiposServicio = [
    {"id_tipo": 1, "nombre": "Peluquería"},
    {"id_tipo": 2, "nombre": "Manicura y Pedicura"},
    {"id_tipo": 3, "nombre": "Depilación"},
    {"id_tipo": 4, "nombre": "Pestañas y Cejas"},
    {"id_tipo": 5, "nombre": "Tratamientos Faciales"},
    {"id_tipo": 6, "nombre": "Tratamientos Corporales"},
    {"id_tipo": 7, "nombre": "Masajes"},
    {"id_tipo": 8, "nombre": "Maquillaje"},
    {"id_tipo": 9, "nombre": "Micropigmentación"},
  ];

  final List<Map<String, dynamic>> _servicios = [
    // Peluquería (1)
    {"id_servicio": 1, "nombre": "Lavado + Peinado", "descripcion": "Lavado y peinado básico para todo tipo de cabello", "precio": 5.0, "duracion": 2.0, "id_tipo": 1},
    {"id_servicio": 2, "nombre": "Lavado + Peinado + Recogido", "descripcion": "Peinado con recogido para eventos o ocasiones especiales", "precio": 12.0, "duracion": 3.0, "id_tipo": 1},
    {"id_servicio": 3, "nombre": "Corte femenino", "descripcion": "Corte de cabello para mujer con lavado incluido", "precio": 5.0, "duracion": 3.0, "id_tipo": 1},
    {"id_servicio": 4, "nombre": "Corte masculino", "descripcion": "Corte de cabello para hombre con lavado incluido", "precio": 2.0, "duracion": 2.0, "id_tipo": 1},
    {"id_servicio": 5, "nombre": "Color completo", "descripcion": "Aplicación de color en todo el cabello", "precio": 8.0, "duracion": 2.5, "id_tipo": 1},
    {"id_servicio": 6, "nombre": "Color raíces", "descripcion": "Aplicación de color solo en raíces", "precio": 5.0, "duracion": 2.5, "id_tipo": 1},
    {"id_servicio": 7, "nombre": "Mechas", "descripcion": "Técnica de coloración parcial para dar luz al cabello", "precio": 10.0, "duracion": 4.0, "id_tipo": 1},
    {"id_servicio": 8, "nombre": "Cambio de estilo + color", "descripcion": "Transformación completa del look con nuevo color", "precio": 15.0, "duracion": 3.0, "id_tipo": 1},
    {"id_servicio": 9, "nombre": "Permanente", "descripcion": "Cambio de forma del cabello mediante técnica permanente", "precio": 10.0, "duracion": 4.0, "id_tipo": 1},
    {"id_servicio": 10, "nombre": "Tratamiento capilar", "descripcion": "Tratamiento nutritivo y reparador para el cabello", "precio": 5.0, "duracion": 3.0, "id_tipo": 1},

    // Manicura y Pedicura (2)
    {"id_servicio": 11, "nombre": "Manicura exprés", "descripcion": "Limpieza y limado de uñas sin esmaltado", "precio": 2.0, "duracion": 0.75, "id_tipo": 2},
    {"id_servicio": 12, "nombre": "Manicura completa semipermanente", "descripcion": "Manicura con esmaltado semipermanente de larga duración", "precio": 5.0, "duracion": 1.5, "id_tipo": 2},
    {"id_servicio": 13, "nombre": "Pedicura semipermanente", "descripcion": "Pedicura con esmaltado semipermanente", "precio": 5.0, "duracion": 1.5, "id_tipo": 2},
    {"id_servicio": 14, "nombre": "Parafina manos", "descripcion": "Tratamiento hidratante con baño de parafina", "precio": 2.0, "duracion": 1.0, "id_tipo": 2},
    {"id_servicio": 15, "nombre": "Uñas artificiales", "descripcion": "Aplicación de uñas postizas con acabado profesional", "precio": 10.0, "duracion": 3.0, "id_tipo": 2},
    {"id_servicio": 16, "nombre": "Manicura semipermanente", "descripcion": "Manicura con esmaltado semipermanente", "precio": 5.0, "duracion": 2.0, "id_tipo": 2},
    {"id_servicio": 17, "nombre": "Manicura normal", "descripcion": "Manicura básica con esmaltado tradicional", "precio": 2.0, "duracion": 1.0, "id_tipo": 2},

    // Depilación (3)
    {"id_servicio": 18, "nombre": "Depilación facial", "descripcion": "Eliminación de vello en labio, cejas, mentón y zonas faciales", "precio": 3.0, "duracion": 0.5, "id_tipo": 3},
    {"id_servicio": 19, "nombre": "Diseño de cejas", "descripcion": "Moldeado y definición de cejas según el rostro", "precio": 2.0, "duracion": 0.5, "id_tipo": 3},
    {"id_servicio": 20, "nombre": "Depilación de axilas", "descripcion": "Eliminación de vello en la zona de las axilas", "precio": 4.0, "duracion": 0.3, "id_tipo": 3},
    {"id_servicio": 21, "nombre": "Depilación de brazos", "descripcion": "Depilación completa de ambos brazos", "precio": 6.0, "duracion": 0.5, "id_tipo": 3},
    {"id_servicio": 22, "nombre": "Depilación medias piernas", "descripcion": "Depilación desde rodilla hasta tobillo", "precio": 8.0, "duracion": 0.5, "id_tipo": 3},
    {"id_servicio": 23, "nombre": "Depilación piernas completas", "descripcion": "Depilación total de ambas piernas", "precio": 10.0, "duracion": 1.0, "id_tipo": 3},
    {"id_servicio": 24, "nombre": "Depilación ingles", "descripcion": "Depilación básica en zona íntima", "precio": 4.0, "duracion": 0.5, "id_tipo": 3},
    {"id_servicio": 25, "nombre": "Depilación brasileña", "descripcion": "Depilación íntima estilo brasileño", "precio": 5.0, "duracion": 0.75, "id_tipo": 3},
    {"id_servicio": 26, "nombre": "Depilación integral", "descripcion": "Depilación completa en zona íntima", "precio": 6.0, "duracion": 0.75, "id_tipo": 3},
    {"id_servicio": 27, "nombre": "Depilación espalda", "descripcion": "Eliminación de vello en espalda completa", "precio": 4.0, "duracion": 0.75, "id_tipo": 3},
    {"id_servicio": 28, "nombre": "Depilación abdomen", "descripcion": "Eliminación de vello en zona abdominal", "precio": 3.0, "duracion": 0.5, "id_tipo": 3},
    {"id_servicio": 29, "nombre": "Pack completo", "descripcion": "Depilación de cejas, labio, axilas, piernas completas e ingles", "precio": 18.0, "duracion": 1.5, "id_tipo": 3},

    // Pestañas y Cejas (4)
    {"id_servicio": 30, "nombre": "Lifting pestañas", "descripcion": "Elevación de pestañas naturales para efecto rizado", "precio": 8.0, "duracion": 0.75, "id_tipo": 4},
    {"id_servicio": 31, "nombre": "Laminado cejas", "descripcion": "Alisado y fijación de cejas para forma definida", "precio": 8.0, "duracion": 0.75, "id_tipo": 4},
    {"id_servicio": 32, "nombre": "Tinte pestañas", "descripcion": "Coloración de pestañas para mayor intensidad", "precio": 5.0, "duracion": 0.5, "id_tipo": 4},
    {"id_servicio": 33, "nombre": "Lifting + Tinte pestañas", "descripcion": "Elevación y coloración de pestañas en una sola sesión", "precio": 12.0, "duracion": 1.0, "id_tipo": 4},

    // Tratamientos Faciales (5)
    {"id_servicio": 34, "nombre": "Drenaje linfático facial", "descripcion": "Masaje facial para mejorar circulación y eliminar toxinas", "precio": 3.0, "duracion": 1.0, "id_tipo": 5},
    {"id_servicio": 35, "nombre": "Higiene facial", "descripcion": "Limpieza profunda de la piel del rostro", "precio": 0.0, "duracion": 1.5, "id_tipo": 5},
    {"id_servicio": 36, "nombre": "Profunda facial", "descripcion": "Tratamiento facial intensivo con extracción y mascarilla", "precio": 15.0, "duracion": 1.5, "id_tipo": 5},
    {"id_servicio": 37, "nombre": "Hidratación facial", "descripcion": "Tratamiento para restaurar la hidratación de la piel", "precio": 15.0, "duracion": 1.5, "id_tipo": 5},
    {"id_servicio": 38, "nombre": "Antienvejecimiento", "descripcion": "Tratamiento facial para reducir signos de edad", "precio": 15.0, "duracion": 1.5, "id_tipo": 5},
    {"id_servicio": 39, "nombre": "Vitamina C", "descripcion": "Tratamiento facial antioxidante con vitamina C", "precio": 15.0, "duracion": 1.5, "id_tipo": 5},
    {"id_servicio": 40, "nombre": "Pieles grasas", "descripcion": "Tratamiento facial para controlar el exceso de grasa", "precio": 15.0, "duracion": 1.5, "id_tipo": 5},
    {"id_servicio": 41, "nombre": "Despigmentante", "descripcion": "Tratamiento para reducir manchas y unificar tono", "precio": 15.0, "duracion": 1.5, "id_tipo": 5},
    {"id_servicio": 42, "nombre": "Bolsas y ojeras", "descripcion": "Tratamiento para mejorar la apariencia del contorno de ojos", "precio": 15.0, "duracion": 1.5, "id_tipo": 5},

    // Tratamientos Corporales (6)
    {"id_servicio": 43, "nombre": "Drenaje linfático corporal", "descripcion": "Masaje corporal para mejorar circulación y eliminar líquidos", "precio": 6.0, "duracion": 1.5, "id_tipo": 6},
    {"id_servicio": 44, "nombre": "Drenaje linfático completo", "descripcion": "Masaje completo para activar el sistema linfático", "precio": 8.0, "duracion": 2.5, "id_tipo": 6},
    {"id_servicio": 45, "nombre": "Exfoliación corporal", "descripcion": "Eliminación de células muertas y renovación de la piel", "precio": 10.0, "duracion": 1.0, "id_tipo": 6},

    // Masajes (7)
    {"id_servicio": 46, "nombre": "Masaje craneofacial", "descripcion": "Masaje relajante en cabeza y rostro", "precio": 10.0, "duracion": 0.75, "id_tipo": 7},
    {"id_servicio": 47, "nombre": "Masaje de espalda", "descripcion": "Masaje descontracturante en la zona dorsal", "precio": 10.0, "duracion": 0.75, "id_tipo": 7},
    {"id_servicio": 48, "nombre": "Masaje piernas circulatorio", "descripcion": "Masaje para mejorar la circulación en las piernas", "precio": 10.0, "duracion": 0.75, "id_tipo": 7},
    {"id_servicio": 49, "nombre": "Masaje relajante corporal completo", "descripcion": "Masaje relajante de cuerpo entero", "precio": 15.0, "duracion": 1.5, "id_tipo": 7},

    // Maquillaje (8)
    {"id_servicio": 50, "nombre": "Maquillaje de día + hidratación facial", "descripcion": "Maquillaje de día con preparación e hidratación del rostro", "precio": 5.0, "duracion": 1.5, "id_tipo": 8},
    {"id_servicio": 51, "nombre": "Maquillaje día/tarde/noche", "descripcion": "Maquillaje profesional adaptado al momento del día", "precio": 10.0, "duracion": 1.5, "id_tipo": 8},

    // Micropigmentación (9)
    {"id_servicio": 52, "nombre": "Micropigmentación (desde abril)", "descripcion": "Tratamiento de micropigmentación semipermanente", "precio": 50.0, "duracion": 4.0, "id_tipo": 9},
  ];

  List<Map<String, dynamic>> get tiposServicio => _tiposServicio;
  List<Map<String, dynamic>> get servicios => _servicios;

  List<Map<String, dynamic>> getServiciosPorTipo(int idTipo) {
    return _servicios.where((s) => s["id_tipo"] == idTipo).toList();
  }
  // 🔎 Buscar servicios por texto
  List<Map<String, dynamic>> buscarServicios(String query) {
    final q = query.toLowerCase();
    return _servicios.where((s) {
      return (s["nombre"] as String).toLowerCase().contains(q) ||
             (s["descripcion"] as String).toLowerCase().contains(q);
    }).toList();
  }
}
