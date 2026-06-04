import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:peluqueria/models/cita/cita_model.dart';
import 'package:peluqueria/services/user_preferences.dart';
import 'package:peluqueria/config/traducciones.dart'; 

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// --- INICIALIZACIÓN ESTÁTICA ---
  /// Ahora usa la instancia interna para evitar errores de "static access"
  static Future<void> init() async {
    final service = NotificationService(); // Accedemos a la instancia singleton
    
    if (service._initialized) return;

    // 1. Configurar Timezones de forma precisa usando flutter_timezone
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint("🌍 NotificationService: Timezone configurado a $timeZoneName");
    } catch (e) {
      debugPrint("⚠️ Error configurando timezone específico, usando UTC: $e");
      tz.setLocalLocation(tz.UTC);
    }

    // 2. Configuración Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await service._plugin.initialize(
      const InitializationSettings(android: androidSettings),
    );

    // 3. Solicitar permisos obligatorios en Android 13+ y alarmas exactas para segundo plano
    final androidImplementation = service._plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Permiso para mostrar notificaciones (Android 13+)
      final hasPerm = await androidImplementation.requestNotificationsPermission();
      debugPrint("🔔 Permiso de notificaciones concedido: $hasPerm");
      
      // Permiso para programar alarmas exactas (Android 13/14+)
      try {
        final hasAlarmPerm = await androidImplementation.requestExactAlarmsPermission();
        debugPrint("⏰ Permiso de alarmas exactas concedido: $hasAlarmPerm");
      } catch (e) {
        debugPrint("⚠️ No se pudo solicitar/verificar el permiso de alarmas exactas: $e");
      }
    }

    service._initialized = true;
    debugPrint("✅ NotificationService: Inicializado correctamente");
  }

  /// --- PROGRAMACIÓN DESDE CALENDARIO ---
  static Future<void> programarRecordatorioCita({
    required int idCita,
    required DateTime fechaCompleta,
    required String nombreServicio,
  }) async {
    final service = NotificationService();
    if (!service._initialized) await init();

    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(fechaCompleta);

    // Cancelar previos (limpieza)
    await service._plugin.cancel(idCita * 10);
    await service._plugin.cancel(idCita * 10 + 1);

    // 24 Horas antes
    final remind24h = fechaCompleta.subtract(const Duration(hours: 24));
    if (remind24h.isAfter(now)) {
      final title = await service._translateStatic('notif_24h_title', args: {'service': nombreServicio});
      final body = await service._translateStatic('notif_24h_body', args: {'time': timeStr});
      await service._zonedSchedule(idCita * 10, title, body, remind24h);
    }

    // 1 Hora antes
    final remind1h = fechaCompleta.subtract(const Duration(hours: 1));
    if (remind1h.isAfter(now)) {
      final title = await service._translateStatic('notif_1h_title', args: {'service': nombreServicio});
      final body = await service._translateStatic('notif_1h_body', args: {'time': timeStr});
      await service._zonedSchedule(idCita * 10 + 1, title, body, remind1h);
    }
  }

  /// --- MÉTODOS PRIVADOS ---
  
  Future<String> _translateStatic(String key, {Map<String, String>? args}) async {
    final lang = await UserPreferences().getLanguage();
    String text = translationData[key]?[lang] ?? key;
    args?.forEach((k, v) => text = text.replaceAll('{$k}', v));
    return text;
  }

  Future<void> _zonedSchedule(int id, String title, String body, DateTime date) async {
    await _plugin.zonedSchedule(
      id, title, body,
      tz.TZDateTime.from(date, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'cita_alerts', 'Alertas de Citas',
          channelDescription: 'Recordatorios de tus citas de peluquería',
          importance: Importance.max, priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Si necesitas usar el modelo Cita directamente:
  Future<void> scheduleReminders(Cita cita) async {
    final parts = cita.horaInicio.split(':');
    final DateTime dt = DateTime(
      cita.fecha.year, cita.fecha.month, cita.fecha.day,
      int.parse(parts[0]), int.parse(parts[1])
    );
    await programarRecordatorioCita(
      idCita: cita.idCita, 
      fechaCompleta: dt, 
      nombreServicio: cita.nombreServicio
    );
  }
}