import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();


static Future<void> mostrarNotificacionInmediata() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'bernat_citas_v2',
    'Recordatorios de Citas',
    importance: Importance.max,
    priority: Priority.high,
    fullScreenIntent: true, // Esto fuerza la aparición
  );

  await _notifications.show(
    999,
    'Prueba Instantánea',
    'Si ves esto, la configuración es correcta',
    const NotificationDetails(android: androidDetails),
  );
}
  static Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notifications.initialize(
      initializationSettings, // Parámetro posicional
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        debugPrint("Notificación tocada: ${details.payload}");
      },
    );
    
    // Permisos
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  static Future<void> programarRecordatorioCita(int id, DateTime fechaCita) async {
    final ahora = DateTime.now();

    // 1. Definir momentos de aviso
    final aviso24h = fechaCita.subtract(const Duration(days: 1));
    final aviso1h = fechaCita.subtract(const Duration(hours: 1));

    // --- PROGRAMAR AVISO 24 HORAS ---
    if (aviso24h.isAfter(ahora)) {
      await _agendar(
        id: id + 1000, 
        titulo: 'Bernat Experience',
        cuerpo: 'Mañana tienes tu cita a las ${DateFormat('HH:mm').format(fechaCita)}',
        fecha: aviso24h,
      );
      debugPrint("✅ Aviso 24h programado");
    } else {
      debugPrint("⚠️ Muy tarde para aviso de 24h");
    }

    // --- PROGRAMAR AVISO 1 HORA ---
    if (aviso1h.isAfter(ahora)) {
      await _agendar(
        id: id + 2000,
        titulo: '¡Tu cita es pronto!',
        cuerpo: 'Te esperamos en 1 hora (${DateFormat('HH:mm').format(fechaCita)})',
        fecha: aviso1h,
      );
      debugPrint("✅ Aviso 1h programado");
    }
  }

  // Método privado para evitar errores de parámetros posicionales
static Future<void> _agendar({
    required int id,
    required String titulo,
    required String cuerpo,
    required DateTime fecha,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'bernat_citas_v2',
      'Recordatorios de Citas',
      channelDescription: 'Canal para avisos de citas de peluquería',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher', // <--- AÑADE ESTA LÍNEA AQUÍ
    );

    await _notifications.zonedSchedule(
      id,
      titulo,
      cuerpo,
      tz.TZDateTime.from(fecha, tz.local),
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Cambiado a exact para que no se retrase
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'cita_$id',
    );
  }

  static Future<void> cancelarNotificacion(int id) async {
    await _notifications.cancel(id + 1000);
    await _notifications.cancel(id + 2000);
    debugPrint("🗑️ Avisos para cita $id cancelados");
  }
}