import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzData;
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/providers/reminder_count_provider.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static List<Map<String, dynamic>> get scheduledReminders => Hive.box(
    'remindersBox',
  ).values.cast<Map>().toList().cast<Map<String, dynamic>>();

  static Future<void> init() async {
    tzData.initializeTimeZones();

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);

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
    if (scheduledTime.isAfter(DateTime.now())) {
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
        matchDateTimeComponents: DateTimeComponents.time,
      );

      final box = Hive.box('remindersBox');
      await box.put(id, {
        'id': id,
        'body': body,
        'time': scheduledTime,
        'category': category,
      });

      _updateGlobalReminderCount();

      debugPrint("✅ Reminder scheduled and saved in Hive (id: $id)");
    } else {
      debugPrint("❌ Skipping reminder: $scheduledTime is in the past.");
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    final box = Hive.box('remindersBox');
    await box.delete(id);

    _updateGlobalReminderCount();

    debugPrint("🚫 Reminder cancelled and removed from Hive (id: $id)");
  }

  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
    await Hive.box('remindersBox').clear();

    _updateGlobalReminderCount();

    debugPrint("🚫 All reminders cancelled and cleared from Hive");
  }

  static void _updateGlobalReminderCount() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Provider.of<ReminderCountProvider>(
        context,
        listen: false,
      ).updateReminderCount();
    }
  }
}
