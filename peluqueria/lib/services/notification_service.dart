import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

import '../config/api_config.dart'; // Importante para usar ApiConfig.baseUrl
import '../services/user_preferences.dart'; // Para obtener el userId

class NotificationService {
  // Instancia única del plugin
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializa el servicio de notificaciones
  /// Se debe llamar en el main.dart: await NotificationService.init();
  static Future<void> init() async {
    tz.initializeTimeZones(); // Configura las zonas horarias

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint("Notificación pulsada: ${details.payload}");
      },
    );
  }

 static Future<void> vincularDispositivoConBackend(int idCliente) async {
    final deviceInfo = DeviceInfoPlugin();
    
    try {
      String deviceId = '';
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown_ios';
      }

      // El token que enviaremos (tu Java espera un Map con la clave "token")
      String tokenAutomatico = "token_${deviceId}_$idCliente";

      // IMPORTANTE: Tu Java usa @PathVariable Long clienteId y @RequestMapping("/api/fcm")
      // Por lo tanto, la URL debe ser: /api/fcm/token/{idCliente}
      final String url = '${ApiConfig.baseUrl}/api/fcm/token/$idCliente';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        // Tu Java espera @RequestBody Map<String, String> body con la clave "token"
        body: jsonEncode({
          'token': tokenAutomatico,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Token registrado en Java para cliente $idCliente");
      } else {
        debugPrint("❌ Error servidor: ${response.statusCode} - ${response.body}");
        debugPrint("🔗 Intentaste llamar a: $url");
      }
    } catch (e) {
      debugPrint("⚠️ Error de conexión: $e");
    }
  }

  // --- PROGRAMACIÓN LOCAL ---

  /// Programa un recordatorio para una cita específica
  /// Se ejecuta 1 hora antes de la cita por defecto
  /// Programa un recordatorio para una cita específica
  /// Se ejecuta 24 horas (1 día) antes de la cita
  static Future<void> programarRecordatorioCita(
    int id,
    DateTime fechaCita,
  ) async {
    // CAMBIA ESTA LÍNEA: de hours: 1 a days: 1
    final momentoNotificacion = fechaCita.subtract(const Duration(days: 1));

    // Si la cita es para mañana y ya faltan menos de 24 horas, 
    // el recordatorio sería para "un momento ya pasado".
    if (momentoNotificacion.isBefore(DateTime.now())) {
      debugPrint("⚠️ Falta menos de un día para la cita, programando aviso inmediato...");
      // Opcional: Si quieres que avise de todos modos aunque falte menos de un día, 
      // podrías programarla para dentro de 5 segundos:
      // final momentoNotificacion = DateTime.now().add(Duration(seconds: 5));
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      'Recordatorio de Cita',
      'Mañana tienes una cita a las ${fechaCita.hour}:${fechaCita.minute.toString().padLeft(2, '0')} h.',
      tz.TZDateTime.from(momentoNotificacion, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'citas_channel',
          'Recordatorios de Citas',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'reserva_$id',
    );

    debugPrint("🔔 Notificación programada para el día anterior: $momentoNotificacion");
  }

  /// Cancela una notificación específica (útil si el cliente cancela la cita)
  static Future<void> cancelarNotificacion(int id) async {
    await _notificationsPlugin.cancel(id);
    debugPrint("🔔 Notificación $id cancelada.");
  }
}