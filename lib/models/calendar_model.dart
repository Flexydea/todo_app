import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'calendar_model.g.dart';

@HiveType(typeId: 0)
class Calendar extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String time; // ← now store time as a string like "HH:mm"

  @HiveField(3)
  bool done;

  @HiveField(4)
  String category;

  @HiveField(5)
  int notificationId;

  @HiveField(6)
  String? reminderTime; // ← optional reminder time stored as string too

  Calendar({
    required this.title,
    required this.date,
    required TimeOfDay time,
    this.done = false,
    this.category = 'Work',
    TimeOfDay? reminderTime,
    int? notificationId,
  }) : time = _formatTimeOfDay(time),
       reminderTime = reminderTime != null
           ? _formatTimeOfDay(reminderTime)
           : null,
       notificationId = notificationId ?? DateTime.now().millisecondsSinceEpoch;

  static String _formatTimeOfDay(TimeOfDay t) =>
      '${t.hour}:${t.minute.toString().padLeft(2, '0')}';

  static TimeOfDay parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  TimeOfDay get parsedTime => parseTime(time);
  TimeOfDay? get parsedReminderTime =>
      reminderTime != null ? parseTime(reminderTime!) : null;

  Calendar copyWith({
    String? title,
    DateTime? date,
    TimeOfDay? time,
    bool? done,
    String? category,
    TimeOfDay? reminderTime,
    int? notificationId,
  }) {
    return Calendar(
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? parsedTime,
      done: done ?? this.done,
      category: category ?? this.category,
      reminderTime: reminderTime ?? parsedReminderTime,
      notificationId: notificationId ?? this.notificationId,
    );
  }
}
