import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/models/calendar_model.dart';
import 'package:todo_app/screens/edit_calendar_task_screen.dart';
import 'package:todo_app/services/notification_service.dart';
import 'package:lottie/lottie.dart';

class TaskCard extends StatelessWidget {
  final Calendar task;
  final dynamic hiveKey;

  const TaskCard({Key? key, required this.task, required this.hiveKey})
    : super(key: key);

  void _showDeleteAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.grey[900],
        child: SizedBox(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/delete.json',
                repeat: false,
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 10),
              const Text(
                'Task deleted!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(hiveKey),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        final calendarBox = Hive.box<Calendar>('calendarBox');

        // Cancel reminder
        NotificationService.cancelNotification(task.notificationId);

        // Delete from Hive
        calendarBox.delete(hiveKey);
        // Animation
        _showDeleteAnimation(context);
      },
      child: GestureDetector(
        onTap: () async {
          final updated = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditCalendarTaskScreen(
                task: task,
                onSave:
                    (
                      updatedTask,
                    ) {}, // you can pass an empty function or implement it
              ),
            ),
          );

          if (updated != null && updated is Calendar) {
            final calendarBox = Hive.box<Calendar>('calendarBox');

            // Save the updated task
            calendarBox.put(hiveKey, updated);

            // Cancel the old notification
            await NotificationService.cancelNotification(
              updated.notificationId,
            );

            // Schedule a new one
            await NotificationService.scheduleNotification(
              id: updated.notificationId,
              title: updated.title,
              body: 'Reminder for ${updated.title}',
              scheduledTime: DateTime(
                updated.date.year,
                updated.date.month,
                updated.date.day,
                updated.parsedTime.hour,
                updated.parsedTime.minute,
              ),
              category: updated.category,
            );
          }
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            leading: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
            ),
            title: Text(task.title),
            subtitle: Text(task.parsedTime.format(context)),
            trailing: Text(
              task.category,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
