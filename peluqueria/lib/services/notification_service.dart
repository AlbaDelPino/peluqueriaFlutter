import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> init() async {
    tz.initializeTimeZones();
    
    // Configuración Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notifications.initialize(initializationSettings);

    // Escuchar mensajes de Firebase en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _mostrarNotificacionDeFCM(message);
    });
  }

  // --- VINCULACIÓN CON SPRING BOOT ---
  static Future<void> vincularDispositivoConBackend(int clienteId) async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true, badge: true, sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _fcm.getToken();
      if (token != null) {
        debugPrint("🚀 [FCM] Token: $token");
        await _enviarTokenAlServidor(clienteId, token);
      }
    }
  }

  static Future<void> _enviarTokenAlServidor(int clienteId, String token) async {
    try {
      // Reemplaza con tu IP de 'config api+'
      final url = Uri.parse("http://10.0.2.2:8080/api/fcm/token/$clienteId");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token}),
      );
      if (response.statusCode == 200) {
        debugPrint("✅ Token guardado en servidor");
      }
    } catch (e) {
      debugPrint("❌ Error vinculando token: $e");
    }
  }

  // --- NOTIFICACIONES LOCALES (Recordatorios) ---
  static Future<void> programarRecordatorioCita(int id, DateTime fechaCita) async {
    // Ejemplo: Notificar 1 hora antes
    final scheduledDate = fechaCita.subtract(const Duration(hours: 1));
    
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      id,
      'Recordatorio de Cita',
      'Tu cita comienza en 1 hora. ¡Te esperamos!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'bernat_local', 'Recordatorios Locales',
          importance: Importance.max, priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static void _mostrarNotificacionDeFCM(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      await _notifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'bernat_fcm', 'Notificaciones Servidor',
            importance: Importance.max, priority: Priority.high,
          ),
        ),
      );
    }
  }
}