import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static final UserPreferences _instance = UserPreferences._internal();

  factory UserPreferences() {
    return _instance;
  }

  UserPreferences._internal();

  late SharedPreferences _prefs;

  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 🔹 ID
  String get id => _prefs.getString('id') ?? '';
  set id(String value) => _prefs.setString('id', value);

  // 🔹 Contraseña
  String get contrasena => _prefs.getString('contrasena') ?? '';
  set contrasena(String value) => _prefs.setString('contrasena', value);

  // 🔹 Email
  String get email => _prefs.getString('email') ?? '';
  set email(String value) => _prefs.setString('email', value);

  // 🔹 Nombre
  String get nombre => _prefs.getString('nombre') ?? '';
  set nombre(String value) => _prefs.setString('nombre', value);

  // 🔹 Dirección
  String get direccion => _prefs.getString('direccion') ?? '';
  set direccion(String value) => _prefs.setString('direccion', value);

  // 🔹 Avatar (ruta de imagen)
  String get avatarPath => _prefs.getString('avatarPath') ?? '';
  set avatarPath(String value) => _prefs.setString('avatarPath', value);

  // 🔹 Características del cabello (lista guardada como string separado por comas)
  String get caracteristicasCabello => _prefs.getString('caracteristicasCabello') ?? '';
  set caracteristicasCabello(String value) => _prefs.setString('caracteristicasCabello', value);

  // 🔹 Sensibilidades estéticas (lista guardada como string separado por comas)
  String get sensibilidades => _prefs.getString('sensibilidades') ?? '';
  set sensibilidades(String value) => _prefs.setString('sensibilidades', value);

  // 🔹 Observaciones adicionales
  String get observacionesExtra => _prefs.getString('observacionesExtra') ?? '';
  set observacionesExtra(String value) => _prefs.setString('observacionesExtra', value);

  // 🔹 Última página visitada
  String get lastPage => _prefs.getString('lastPage') ?? 'home';
  set lastPage(String value) => _prefs.setString('lastPage', value);
}
