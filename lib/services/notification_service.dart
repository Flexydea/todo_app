// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzData;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final List<Map<String, dynamic>> _scheduledReminders = [];

  static List<Map<String, dynamic>> get scheduledReminders =>
      _scheduledReminders;

  static Future<void> init() async {
    tzData.initializeTimeZones();
    // iOS Settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Android Settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Combine both into InitializationSettings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize timezones
    tzData.initializeTimeZones();

    // Initialize the plugin
    await _notificationsPlugin.initialize(initSettings);

    // Optional: explicitly request permissions for iOS
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String category,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_reminders',
          'Task Reminders',
          channelDescription: 'Task Reminder Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // Prevent duplicates
    _scheduledReminders.removeWhere((r) => r['id'] == id);

    _scheduledReminders.add({
      'id': id,
      'body': body,
      'time': scheduledTime,
      'category': category,
    });
    print("Reminder added: $_scheduledReminders");
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    _scheduledReminders.removeWhere((r) => r['id'] == id);
  }

  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
    _scheduledReminders.clear();
  }
}
