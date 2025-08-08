import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/calendar_model.dart';
import 'package:todo_app/providers/reminder_count_provider.dart';
import 'package:todo_app/services/notification_service.dart';
import 'package:intl/intl.dart';

class UpcomingRemindersScreen extends StatefulWidget {
  const UpcomingRemindersScreen({Key? key}) : super(key: key);

  @override
  State<UpcomingRemindersScreen> createState() =>
      _UpcomingRemindersScreenState();
}

class _UpcomingRemindersScreenState extends State<UpcomingRemindersScreen> {
  List<Map<String, dynamic>> reminders = [];

  @override
  void initState() {
    super.initState();
    loadReminders();
  }

  void loadReminders() {
    final box = Hive.box('remindersBox');

    reminders = box.values
        .cast<Map>()
        .where((r) => r['time'] != null)
        .map((r) => Map<String, dynamic>.from(r))
        .toList()
      ..sort(
        (a, b) => DateTime.parse(
          a['time'].toString(),
        ).compareTo(DateTime.parse(b['time'].toString())),
      );

    setState(() {});
  }

  void _showDeleteReminderAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.grey[900],
        child: Container(
          padding: const EdgeInsets.all(20),
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
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upcoming Reminders"),
        backgroundColor: Colors.green,
      ),
      body: reminders.isEmpty
          ? const Center(child: Text("No upcoming reminders"))
          : ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                final reminderId = reminder['id'];
                final time = DateTime.parse(reminder['time'].toString());
                final formattedTime = DateFormat(
                  'EEE, MMM d • hh:mm a',
                ).format(time);

                return Dismissible(
                  key: Key(reminderId.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) async {
                    final reminderId = reminder['id'];

                    // Cancel notification
                    await NotificationService.cancelNotification(reminderId);

                    // Show animation
                    _showDeleteReminderAnimation(context);
                    await Future.delayed(const Duration(seconds: 2));

                    // Delete from remindersBox
                    final reminderBox = Hive.box('remindersBox');
                    await reminderBox.delete(reminderId);

                    // 🔁 Remove reminder from associated task in calendarBox
                    final _calendarBox = Hive.box<Calendar>('calendarBox');

                    for (var key in _calendarBox.keys) {
                      final task = _calendarBox.get(key);
                      if (task != null && task.notificationId == reminderId) {
                        final updated = task.copyWith(
                          reminderTime: null,
                          notificationId: null,
                        );
                        await _calendarBox.put(key, updated);
                        break;
                      }
                    }

                    // Reload UI
                    loadReminders();

                    // Update badge
                    Provider.of<ReminderCountProvider>(
                      context,
                      listen: false,
                    ).updateReminderCount();
                  },
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active),
                    title: Text(reminder['body']),
                    subtitle: Text(formattedTime),
                    trailing: Text(reminder['category']),
                  ),
                );
              },
            ),
    );
  }
}
