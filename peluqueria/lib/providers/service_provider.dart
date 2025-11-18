import 'package:flutter/material.dart';
import '../models/serive.dart';

class ServiceProvider with ChangeNotifier {
  final Map<String, List<Service>> _services = {
    "Peluquería": [
      Service(name: "Lavado + Peinado", duration: "2h", price: 5),
      Service(name: "Lavado + Peinado + Recogido", duration: "3h", price: 12),
      Service(name: "Corte femenino", duration: "3h", price: 5),
      Service(name: "Corte masculino", duration: "2h", price: 2),
      Service(name: "Color completo", duration: "2.5h", price: 8),
      Service(name: "Raíces", duration: "2.5h", price: 5),
      Service(name: "Mechas", duration: "4h", price: 10),
      Service(name: "Cambio de estilo + color", duration: "3h", price: 15),
      Service(name: "Permanente", duration: "4h", price: 10),
      Service(name: "Tratamiento capilar", duration: "3h", price: 5),
    ],
    "Manicura y Pedicura": [
      Service(name: "Manicura exprés", duration: "45'", price: 2),
      Service(
        name: "Manicura completa semipermanente",
        duration: "1h 30'",
        price: 5,
      ),
      Service(
        name: "Pedicura + esmaltado semipermanente",
        duration: "1h 30'",
        price: 5,
      ),
      Service(name: "Tratamiento parafina", duration: "1h", price: 2),
      Service(name: "Uñas artificiales", duration: "3h", price: 10),
      Service(name: "Manicura semipermanente", duration: "2h", price: 5),
      Service(name: "Manicura normal", duration: "1h", price: 2),
    ],
    "Depilación": [
      Service(
        name: "Facial (labio, cejas, mentón, etc.)",
        duration: "30'",
        price: 3,
      ),
      Service(name: "Diseño de cejas", duration: "30'", price: 2),
      Service(name: "Axilas", duration: "20'", price: 4),
      Service(name: "Brazos", duration: "30'", price: 6),
      Service(name: "Medias piernas", duration: "30'", price: 8),
      Service(name: "Piernas completas", duration: "1h", price: 10),
      Service(name: "Ingles", duration: "30'", price: 4),
      Service(name: "Ingles brasileña", duration: "45'", price: 5),
      Service(name: "Ingles integral", duration: "45'", price: 6),
      Service(name: "Espalda", duration: "45'", price: 4),
      Service(name: "Abdomen", duration: "30'", price: 3),
      Service(name: "Pack completo", duration: "1h 30'", price: 18),
    ],
    "Pestañas y Cejas": [
      Service(name: "Lifting pestañas", duration: "45'", price: 8),
      Service(name: "Laminado cejas", duration: "45'", price: 8),
      Service(name: "Tinte pestañas", duration: "30'", price: 5),
      Service(name: "Lifting + tinte pestañas", duration: "1h", price: 12),
    ],
    "Tratamientos Faciales": [
      Service(name: "Drenaje linfático facial", duration: "1h", price: 3),
      Service(
        name: "Higiene facial",
        duration: "1h 30'",
        price: 0,
      ), // sin precio indicado
      Service(name: "Profunda facial", duration: "1h 30'", price: 15),
      Service(name: "Hidratación facial", duration: "1h 30'", price: 15),
      Service(name: "Antienvejecimiento", duration: "1h 30'", price: 15),
      Service(name: "Vitamina C", duration: "1h 30'", price: 15),
      Service(name: "Pieles grasas", duration: "1h 30'", price: 15),
      Service(name: "Despigmentante", duration: "1h 30'", price: 15),
      Service(name: "Bolsas y ojeras", duration: "1h 30'", price: 15),
    ],
    "Tratamientos Corporales": [
      Service(name: "Drenaje linfático corporal", duration: "1h 30'", price: 6),
      Service(name: "Drenaje linfático completo", duration: "2h 30'", price: 8),
      Service(name: "Exfoliación corporal", duration: "1h", price: 10),
      Service(name: "Hidratación corporal", duration: "1h", price: 10),
      Service(name: "Anticelulítico", duration: "1h 30'", price: 20),
      Service(name: "Reductor", duration: "1h 30'", price: 20),
      Service(name: "Mejora circulación", duration: "1h 30'", price: 20),
      Service(name: "Estrés y fatiga emocional", duration: "1h 30'", price: 20),
    ],
    "Masajes": [
      Service(name: "Craneofacial", duration: "45'", price: 10),
      Service(name: "Espalda", duration: "45'", price: 10),
      Service(name: "Piernas circulatorio", duration: "45'", price: 10),
      Service(name: "Complementario zonal", duration: "45'", price: 10),
      Service(name: "Anticelulítico zonal", duration: "45'", price: 10),
      Service(name: "Reductor zonal", duration: "45'", price: 10),
      Service(
        name: "Relajante corporal completo",
        duration: "1h 30'",
        price: 15,
      ),
      Service(name: "Masaje a 4 manos", duration: "1h 30'", price: 15),
      Service(name: "Masaje del mundo corporal", duration: "1h 30'", price: 15),
    ],
    "Maquillaje": [
      Service(
        name: "Maquillaje de día + hidratación facial",
        duration: "1h 30'",
        price: 5,
      ),
      Service(
        name: "Maquillaje día/tarde/noche",
        duration: "1h 30'",
        price: 10,
      ),
    ],
    "Micropigmentación": [
      Service(
        name: "Micropigmentación (desde abril)",
        duration: "4h",
        price: 50,
      ),
    ],
  };

  Map<String, List<Service>> get services => _services;
}
