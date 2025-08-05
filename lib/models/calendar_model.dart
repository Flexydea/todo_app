import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'calendar_model.g.dart';

@HiveType(typeId: 0)
class Calendar extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final TimeOfDay time;

  @HiveField(3)
  final bool done;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final int? notificationId;

  @HiveField(6)
  final TimeOfDay? reminderTime;

  Calendar({
    required this.title,
    required this.date,
    required this.time,
    required this.done,
    required this.category,
    this.notificationId,
    this.reminderTime,
  });

  Calendar copyWith({
    String? title,
    DateTime? date,
    TimeOfDay? time,
    bool? done,
    String? category,
    int? notificationId,
    TimeOfDay? reminderTime,
  }) {
    return Calendar(
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      done: done ?? this.done,
      category: category ?? this.category,
      notificationId: notificationId ?? this.notificationId,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  // ✅ Optional: Returns reminderTime directly (already a TimeOfDay)
  TimeOfDay? get parsedReminderTime => reminderTime;
}
