import 'package:flutter/services.dart';

final _ajustes = <String>{
  'Ver detalles de perfil',
  'Editar perfil',
  'Cerrar sesión',
};

Future<List<dynamic>> cargarData() async {
    final resp = await rootBundle.loadString('data/menu_opts.json');
    Map dataMap = json.decode(resp);
    print(dataMap['rutas']);
    opciones = dataMap['rutas'];
    return opciones;
  }