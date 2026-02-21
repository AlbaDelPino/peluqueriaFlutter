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
      String modelo = '';

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        modelo = androidInfo.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown_ios';
        modelo = iosInfo.utsname.machine;
      }

      // Generamos un token automático para que no lo tengas que pasar tú
      String tokenAutomatico = "token_${deviceId}_$idCliente";

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/dispositivos/vincular'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'clienteId': idCliente,
          'deviceId': deviceId,
          'token': tokenAutomatico,
          'modelo': modelo,
          'plataforma': Platform.isAndroid ? 'ANDROID' : 'IOS',
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Vinculado cliente $idCliente en ${ApiConfig.baseUrl}");
      }
    } catch (e) {
      debugPrint("⚠️ Error: $e");
    }
  }

  // --- PROGRAMACIÓN LOCAL ---

  /// Programa un recordatorio para una cita específica
  /// Se ejecuta 1 hora antes de la cita por defecto
  static Future<void> programarRecordatorioCita(
    int id,
    DateTime fechaCita,
  ) async {
    // Calculamos el momento de la notificación (ejemplo: 1 hora antes)
    final momentoNotificacion = fechaCita.subtract(const Duration(hours: 1));

    // Si la cita es muy pronto y la hora de notificación ya pasó, no programamos nada
    if (momentoNotificacion.isBefore(DateTime.now())) {
      debugPrint("⚠️ La hora del recordatorio ya ha pasado, no se programará.");
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      id, // ID único de la notificación
      'Recordatorio de Cita',
      'Tienes una cita programada para las ${fechaCita.hour}:${fechaCita.minute.toString().padLeft(2, '0')} h.',
      tz.TZDateTime.from(momentoNotificacion, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'citas_channel', // ID del canal
          'Recordatorios de Citas', // Nombre del canal
          channelDescription: 'Notificaciones para recordatorios de citas',
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
  }

  /// Cancela una notificación específica (útil si el cliente cancela la cita)
  static Future<void> cancelarNotificacion(int id) async {
    await _notificationsPlugin.cancel(id);
    debugPrint("🔔 Notificación $id cancelada.");
  }
}