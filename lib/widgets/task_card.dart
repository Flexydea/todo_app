import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/calendar_model.dart';
import 'package:todo_app/models/category_model.dart';
import 'package:todo_app/providers/reminder_count_provider.dart';
import 'package:todo_app/screens/edit_calendar_task_screen.dart';
import 'package:todo_app/services/notification_service.dart';
import 'package:lottie/lottie.dart';

class TaskCard extends StatelessWidget {
  final Calendar task;
  final dynamic hiveKey;

  const TaskCard({super.key, required this.task, required this.hiveKey});

  void _showDeleteDialog(BuildContext context, dynamic hiveKey) {
    final calendarBox = Hive.box<Calendar>('calendarBox');
    final deletedTask = calendarBox.get(hiveKey);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          height: 200,
          width: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/delete.json',
                repeat: false,
                height: 120,
                width: 120,
              ),
              const SizedBox(height: 10),
              const Text(
                "Task Deleted!",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) Navigator.of(context).pop();

      if (deletedTask != null) {
        calendarBox.delete(hiveKey);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Task deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => calendarBox.put(hiveKey, deletedTask),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final calendarBox = Hive.box<Calendar>('calendarBox');
    final categoryBox = Hive.box<Category>('categoryBox');
    final matchingCategory = categoryBox.values.firstWhere(
      (c) => c.title.toLowerCase().trim() == task.category.toLowerCase().trim(),
      orElse: () =>
          Category(title: '', icon: Icons.help_outline, color: Colors.grey),
    );

    return Dismissible(
      key: ValueKey(hiveKey),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          final updated = task.copyWith(done: !task.done);
          calendarBox.put(hiveKey, updated);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                updated.done
                    ? 'Task marked as completed'
                    : 'Marked as not completed',
              ),
              duration: const Duration(seconds: 1),
            ),
          );
          return false;
        } else {
          _showDeleteDialog(context, hiveKey);
          return false;
        }
      },
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  EditCalendarTaskScreen(task: task, hiveKey: hiveKey),
            ),
          );
        },
        onLongPress: () async {
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );

          if (pickedTime != null) {
            final updatedTask = task.copyWith(reminderTime: pickedTime);

            final calendarBox = Hive.box<Calendar>('calendarBox');
            await calendarBox.put(hiveKey, updatedTask);

            final now = DateTime.now();
            final scheduledDateTime = DateTime(
              updatedTask.date.year,
              updatedTask.date.month,
              updatedTask.date.day,
              pickedTime.hour,
              pickedTime.minute,
            );

            await NotificationService.scheduleNotification(
              id: updatedTask.notificationId,
              title: updatedTask.title,
              body: 'Reminder for ${updatedTask.title}',
              scheduledTime: scheduledDateTime,
              category: updatedTask.category,
            );

            //  Immediately update the red badge count
            Provider.of<ReminderCountProvider>(
              context,
              listen: false,
            ).updateReminderCount();
            // Optional: show a quick confirmation
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Reminder set")));
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: matchingCategory.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    matchingCategory.icon,
                    color: matchingCategory.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: task.done
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.done ? Colors.grey : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.parsedTime.format(context),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (task.parsedReminderTime != null)
                  const Icon(Icons.notifications_active, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
