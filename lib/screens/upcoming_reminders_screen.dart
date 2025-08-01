import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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

    // Load and sort by upcoming time
    reminders =
        box.values
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

  Future<void> deleteReminder(int id) async {
    await NotificationService.cancelNotification(id);
    loadReminders();
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
                final time = DateTime.parse(reminder['time'].toString());
                final formattedTime = DateFormat(
                  'EEE, MMM d • hh:mm a',
                ).format(time);

                return Dismissible(
                  key: Key(reminder['id'].toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => deleteReminder(reminder['id']),
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
