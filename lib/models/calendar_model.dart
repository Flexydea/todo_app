import 'package:flutter/material.dart';

class Calendar {
  final String title;
  final DateTime date;
  final TimeOfDay time;
  final bool done;
  final String category;
  final int notificationId;
  final TimeOfDay? reminderTime;

  Calendar({
    required this.title,
    required this.date,
    required this.time,
    this.done = false,
    this.category = 'Work',
    this.reminderTime,
    int? notificationId,
  }) : notificationId = notificationId ?? DateTime.now().millisecondsSinceEpoch;

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
      time: time ?? this.time,
      done: done ?? this.done,
      category: category ?? this.category,
      reminderTime: reminderTime ?? this.reminderTime,
      notificationId: notificationId ?? this.notificationId,
    );
  }
}
