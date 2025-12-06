import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static final UserPreferences _instance = UserPreferences._internal();
  late SharedPreferences _prefs;

  factory UserPreferences() => _instance;
  UserPreferences._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  //  Token de autenticación
  String get token => _prefs.getString('token') ?? '';
  set token(String value) => _prefs.setString('token', value);
  
  int get clienteId => _prefs.getInt('clienteId') ?? 0;
  set clienteId(int value) => _prefs.setInt('clienteId', value);
  //  Username
  String get username => _prefs.getString('username') ?? '';
  set username(String value) => _prefs.setString('username', value);

  //  Email
  String get email => _prefs.getString('email') ?? '';
  set email(String value) => _prefs.setString('email', value);

  //  Teléfono
  String get telefono => _prefs.getString('telefono') ?? '';
  set telefono(String value) => _prefs.setString('telefono', value);

  //  Dirección
  String get direccion => _prefs.getString('direccion') ?? '';
  set direccion(String value) => _prefs.setString('direccion', value);

  //  Nombre
  String get nombre => _prefs.getString('nombre') ?? '';
  set nombre(String value) => _prefs.setString('nombre', value);

  //  Sensibilidades / alérgenos
  String get sensibilidades => _prefs.getString('sensibilidades') ?? '';
  set sensibilidades(String value) => _prefs.setString('sensibilidades', value);

  //  Observaciones extra
  String get observacionesExtra => _prefs.getString('observacionesExtra') ?? '';
  set observacionesExtra(String value) => _prefs.setString('observacionesExtra', value);

  //  Avatar elegido desde galería/cámara
  String get avatarPath => _prefs.getString('avatarPath') ?? '';
  set avatarPath(String value) => _prefs.setString('avatarPath', value);

  //  Avatar predefinido desde assets
  String get assetAvatar => _prefs.getString('assetAvatar') ?? '';
  set assetAvatar(String value) => _prefs.setString('assetAvatar', value);

  //  Última página visitada
  String get lastPage => _prefs.getString('lastPage') ?? '';
  set lastPage(String value) => _prefs.setString('lastPage', value);

  //  Método para limpiar todo (logout)
  Future<void> clear() async {
    await _prefs.clear();
  }
}
