import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/models/calendar_model.dart';

class ReminderCountProvider extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void loadReminders() {
    final calendarBox = Hive.box<Calendar>('calendarBox');
    _count = calendarBox.values
        .where((task) => task.parsedReminderTime != null)
        .length;
    notifyListeners();
  }

  void updateReminderCount() => loadReminders();
}
