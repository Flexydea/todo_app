// lib/screens/upcoming_reminders_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:todo_app/services/notification_service.dart';

class UpcomingRemindersScreen extends StatefulWidget {
  const UpcomingRemindersScreen({super.key});

  @override
  State<UpcomingRemindersScreen> createState() =>
      _UpcomingRemindersScreenState();
}

class _UpcomingRemindersScreenState extends State<UpcomingRemindersScreen> {
  @override
  Widget build(BuildContext context) {
    final reminders = NotificationService.scheduledReminders;

    final Map<String, IconData> icons = {
      'Work': Icons.work,
      'Personal': Icons.person,
      'Shopping': Icons.shopping_cart,
      'Urgent': Icons.warning,
    };

    final Map<String, Color> colors = {
      'Work': Colors.blue,
      'Personal': Colors.orange,
      'Shopping': Colors.green,
      'Urgent': Colors.red,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Reminders'),
        backgroundColor: Colors.green,
      ),
      body: reminders.isEmpty
          ? const Center(
              child: Text(
                'No reminders set.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                final id = reminder['id'];
                final time = reminder['time'] as DateTime;
                final category = reminder['category'] ?? 'Work';

                return Dismissible(
                  key: Key(id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    final id = reminder['id'];

                    // Cancel system notification
                    await NotificationService.cancelNotification(id);

                    // Play animation
                    _showDeleteAnimation(context);

                    // Delay to let animation play fully
                    await Future.delayed(const Duration(seconds: 2));

                    // ✅ Remove from list AFTER animation completes
                    setState(() {
                      NotificationService.scheduledReminders.removeWhere(
                        (r) => r['id'] == id,
                      );
                    });

                    return true;
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: Icon(
                        icons[category] ?? Icons.label,
                        color: colors[category] ?? Colors.grey,
                      ),
                      title: Text(reminder['body']),
                      subtitle: Text(
                        DateFormat('dd-MM-yy  HH:mm').format(time),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

void _showDeleteAnimation(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: SizedBox(
        height: 200,
        width: 200,
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
              'Reminder deleted!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );

  Future.delayed(const Duration(seconds: 2), () {
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  });
}
