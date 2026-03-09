import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Yerel bildirim servisi: bakım hatırlatmaları için kullanılır.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);

    // Android 13+ için bildirim izni iste.
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Zaman dilimi verilerini yükle.
    tz.initializeTimeZones();

    _initialized = true;
  }

  /// Belirli bir tarihte bakım hatırlatması planlar.
  /// [id]: kayıt id'si; aynı id ile yeniden çağırmak var olan bildirimi günceller.
  Future<void> scheduleMaintenanceReminder({
    required int id,
    required DateTime scheduledAt,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();

    // Geçmiş zamana bildirim planlama.
    if (scheduledAt.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'maintenance_reminders',
      'Bakım Hatırlatmaları',
      channelDescription: 'Yaklaşan veya geciken bakımları hatırlatmak için bildirimler.',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
    );

    const details = NotificationDetails(android: androidDetails);

    final tzDateTime = tz.TZDateTime.from(scheduledAt, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> cancelReminder(int id) async {
    if (!_initialized) await init();
    await _plugin.cancel(id);
  }

  Future<void> cancelAllReminders() async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
  }
}

