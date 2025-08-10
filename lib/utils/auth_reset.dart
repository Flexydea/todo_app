import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/calendar_model.dart';
import 'package:todo_app/models/category_model.dart';
import 'package:todo_app/services/notification_service.dart';
import 'package:todo_app/providers/reminder_count_provider.dart';

Future<void> resetAppDataForNewUser(BuildContext context) async {
  final calendarBox = Hive.box<Calendar>('calendarBox');
  final remindersBox = Hive.box('remindersBox');
  final categoryBox = Hive.box<Category>('categoryBox');

  // Cancel scheduled notifications
  await NotificationService.cancelAll();

  // Clear reminders & tasks
  await remindersBox.clear();
  await calendarBox.clear();

  // Reset categories
  await categoryBox.clear();
  await categoryBox.addAll([
    Category(title: 'Work', icon: Icons.work, color: Colors.blue),
    Category(title: 'Personal', icon: Icons.person, color: Colors.purple),
    Category(
        title: 'Shopping', icon: Icons.shopping_cart, color: Colors.orange),
    Category(title: 'Urgent', icon: Icons.warning, color: Colors.red),
  ]);

  // Update the reminder badge
  if (context.mounted) {
    context.read<ReminderCountProvider>().updateReminderCount();
  }
}
