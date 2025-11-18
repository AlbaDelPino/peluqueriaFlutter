import 'package:flutter/material.dart';

class ServiceProvider with ChangeNotifier {
  final Map<String, List<Map<String, dynamic>>> _services = {
    "Peluquería": [
      {"name": "Lavado + Peinado", "duration": "2h", "price": 5.0},
      {"name": "Lavado + Peinado + Recogido", "duration": "3h", "price": 12.0},
      {"name": "Corte femenino", "duration": "3h", "price": 5.0},
      {"name": "Corte masculino", "duration": "2h", "price": 2.0},
      {"name": "Color completo", "duration": "2.5h", "price": 8.0},
      {"name": "Raíces", "duration": "2.5h", "price": 5.0},
      {"name": "Mechas", "duration": "4h", "price": 10.0},
      {"name": "Cambio de estilo + color", "duration": "3h", "price": 15.0},
      {"name": "Permanente", "duration": "4h", "price": 10.0},
      {"name": "Tratamiento capilar", "duration": "3h", "price": 5.0},
    ],
    "Manicura y Pedicura": [
      {"name": "Manicura exprés", "duration": "45'", "price": 2.0},
      {"name": "Manicura completa semipermanente", "duration": "1h 30'", "price": 5.0},
      {"name": "Pedicura + esmaltado semipermanente", "duration": "1h 30'", "price": 5.0},
      {"name": "Tratamiento parafina", "duration": "1h", "price": 2.0},
      {"name": "Uñas artificiales", "duration": "3h", "price": 10.0},
      {"name": "Manicura semipermanente", "duration": "2h", "price": 5.0},
      {"name": "Manicura normal", "duration": "1h", "price": 2.0},
    ],
    "Depilación": [
      {"name": "Facial (labio, cejas, mentón, etc.)", "duration": "30'", "price": 3.0},
      {"name": "Diseño de cejas", "duration": "30'", "price": 2.0},
      {"name": "Axilas", "duration": "20'", "price": 4.0},
      {"name": "Brazos", "duration": "30'", "price": 6.0},
      {"name": "Medias piernas", "duration": "30'", "price": 8.0},
      {"name": "Piernas completas", "duration": "1h", "price": 10.0},
      {"name": "Ingles", "duration": "30'", "price": 4.0},
      {"name": "Ingles brasileña", "duration": "45'", "price": 5.0},
      {"name": "Ingles integral", "duration": "45'", "price": 6.0},
      {"name": "Espalda", "duration": "45'", "price": 4.0},
      {"name": "Abdomen", "duration": "30'", "price": 3.0},
      {"name": "Pack completo", "duration": "1h 30'", "price": 18.0},
    ],
    // 🔥 Añade aquí el resto de categorías igual que antes
  };

  Map<String, List<Map<String, dynamic>>> get services => _services;
}
