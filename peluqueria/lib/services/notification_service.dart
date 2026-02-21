import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../config/api_config.dart';
import '../services/user_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializa el servicio y configura el canal para notificaciones flotantes
  static Future<void> init() async {
    tz.initializeTimeZones();

    // 1. CONFIGURACIÓN DEL CANAL ANDROID (IMPORTANTE PARA NOTIFICACIONES FLOTANTES)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // ID idéntico al que uses en Java
      'Recordatorios Bernat Experience', // Nombre que verá el usuario en ajustes
      description: 'Canal para recordatorios de citas con prioridad alta.',
      importance: Importance.max, // <--- Esto permite que la notificación flote
      playSound: true,
      enableVibration: true,
    );

    // 2. REGISTRAR EL CANAL EN EL PLUGIN
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint("Notificación pulsada: ${details.payload}");
      },
    );

    // 3. SOLICITAR PERMISOS AUTOMÁTICAMENTE AL INICIAR
    await solicitarPermisos();
  }

  /// Pide permiso al usuario para mostrar alertas, sonidos y banners
  static Future<void> solicitarPermisos() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ El usuario concedió permiso de notificaciones');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('✅ Permiso provisional concedido');
    } else {
      debugPrint('❌ El usuario rechazó los permisos de notificación');
    }
  }

  static Future<void> vincularDispositivoConBackend(int idCliente) async {
    try {
      String? tokenReal = await FirebaseMessaging.instance.getToken();

      if (tokenReal == null) {
        debugPrint("❌ No se pudo obtener el token de Firebase");
        return;
      }

      debugPrint("🚀 Token Real de Firebase: $tokenReal");

      final String url = '${ApiConfig.baseUrl}/api/fcm/token/$idCliente';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': tokenReal}),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Token REAL registrado en Java para cliente $idCliente");
      } else {
        debugPrint("❌ Error servidor: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("⚠️ Error de conexión: $e");
    }
  }

  // --- PROGRAMACIÓN LOCAL ---

  static Future<void> programarRecordatorioCita(
    int id,
    DateTime fechaCita,
  ) async {
    final momentoNotificacion = fechaCita.subtract(const Duration(days: 1));

    if (momentoNotificacion.isBefore(DateTime.now())) {
      debugPrint("⚠️ Cita muy próxima, ignorando programación local...");
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      'Recordatorio de Cita',
      'Mañana tienes una cita a las ${fechaCita.hour}:${fechaCita.minute.toString().padLeft(2, '0')} h.',
      tz.TZDateTime.from(momentoNotificacion, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel', // <--- USAMOS EL CANAL DE ALTA IMPORTANCIA
          'Recordatorios Bernat Experience',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true, // Ayuda en algunos dispositivos a que flote
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'reserva_$id',
    );

    debugPrint("🔔 Notificación programada para: $momentoNotificacion");
  }

  static Future<void> cancelarNotificacion(int id) async {
    await _notificationsPlugin.cancel(id);
    debugPrint("🔔 Notificación $id cancelada.");
  }
}
