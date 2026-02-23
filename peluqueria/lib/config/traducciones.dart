import 'package:flutter/material.dart';

// --- MAPA GLOBAL DE TRADUCCIONES ---
// Lo sacamos fuera para que NotificationService pueda acceder sin context
final Map<String, Map<String, String>> translationData = {
  // --- LOGIN SCREEN ---
  'NOMBRE DE USUARIO': {'es': 'NOMBRE DE USUARIO', 'en': 'USERNAME'},
  '¿Olvidaste tu clave?': {'es': '¿Olvidaste tu clave?', 'en': 'Forgot your password?'},
  'INICIAR SESIÓN': {'es': 'INICIAR SESIÓN', 'en': 'LOG IN'},
  'Continuar con Google': {'es': 'Continuar con Google', 'en': 'Continue with Google'},
  '¿Eres nuevo aquí? ': {'es': '¿Eres nuevo aquí? ', 'en': 'Are you new here? '},
  'Crea una cuenta': {'es': 'Crea una cuenta', 'en': 'Create an account'},
  'Usuario o contraseña incorrectos': {'es': 'Usuario o contraseña incorrectos', 'en': 'Incorrect username or password'},
  'Error de conexión con el servidor': {'es': 'Error de conexión con el servidor', 'en': 'Server connection error'},

  // --- SIGNUP SCREEN ---
  'UNIRSE A BERNAT': {'es': 'UNIRSE A BERNAT', 'en': 'JOIN BERNAT'},
  'USUARIO': {'es': 'USUARIO', 'en': 'USERNAME'},
  'NOMBRE COMPLETO': {'es': 'NOMBRE COMPLETO', 'en': 'FULL NAME'},
  'EMAIL': {'es': 'EMAIL', 'en': 'EMAIL'},
  'TELÉFONO': {'es': 'TELÉFONO', 'en': 'PHONE NUMBER'},
  'CONTRASEÑA': {'es': 'CONTRASEÑA', 'en': 'PASSWORD'},
  'CONFIRMAR CONTRASEÑA': {'es': 'CONFIRMAR CONTRASEÑA', 'en': 'CONFIRM PASSWORD'},
  'Acepto los ': {'es': 'Acepto los ', 'en': 'I accept the '},
  'términos y condiciones': {'es': 'términos y condiciones', 'en': 'terms and conditions'},
  'CREAR MI CUENTA': {'es': 'CREAR MI CUENTA', 'en': 'CREATE ACCOUNT'},
  '¡REGISTRO COMPLETADO!': {'es': '¡REGISTRO COMPLETADO!', 'en': 'REGISTRATION COMPLETE!'},
  'Tu cuenta ha sido creada correctamente.': {'es': 'Tu cuenta ha sido creada correctamente.', 'en': 'Your account has been successfully created.'},
  'ENTENDIDO': {'es': 'ENTENDIDO', 'en': 'GOT IT'},

  // --- VALIDACIONES ---
  'Campo obligatorio': {'es': 'Campo obligatorio', 'en': 'Required field'},
  'La contraseña es obligatoria': {'es': 'La contraseña es obligatoria', 'en': 'Password is required'},
  'Repite la contraseña': {'es': 'Repite la contraseña', 'en': 'Repeat your password'},
  // ... (Agrega aquí el resto de tus validaciones del código original)

  // --- NOTIFICACIONES ---
  'notif_booked_title': {'es': '¡Cita Reservada!', 'en': 'Appointment Booked!'},
  'notif_booked_body': {
    'es': 'Tu cita para {service} el {date} a las {time} ha sido confirmada.',
    'en': 'Your appointment for {service} on {date} at {time} is confirmed.'
  },
  'notif_24h_title': {'es': 'Recordatorio: Cita de {service}', 'en': 'Reminder: {service} Appointment'},
  'notif_24h_body': {
    'es': 'Mañana tienes una cita a las {time}. ¡Te esperamos!',
    'en': 'You have an appointment tomorrow at {time}. See you there!'
  },
  'notif_1h_title': {'es': '¡Te vemos en 1 hora!', 'en': 'See you in 1 hour!'},
  'notif_1h_body': {
    'es': 'Tu cita para {service} empieza a las {time}.',
    'en': 'Your {service} appointment starts at {time}.'
  },
};

extension Trans on String {
  String tr(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return translationData[this]?[lang] ?? this;
  }
}