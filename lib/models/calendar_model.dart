// lib/models/calendar_model.dart
import 'package:flutter/material.dart';

class Calendar {
  final String title;
  final DateTime date;
  final TimeOfDay time;
  final bool done;
  final String category;

  Calendar({
    required this.title,
    required this.date,
    required this.time,
    this.done = false,
    this.category = 'Work',
  });

  Calendar copyWith({
    String? title,
    DateTime? date,
    TimeOfDay? time,
    bool? done,
    String? category,
  }) {
    return Calendar(
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      done: done ?? this.done,
      category: category ?? this.category,
    );
  }
}
