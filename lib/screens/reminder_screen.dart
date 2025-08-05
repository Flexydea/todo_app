import 'package:flutter/material.dart';
import 'package:todo_app/models/calendar_model.dart';

class ReminderScreen extends StatefulWidget {
  final List<Calendar> tasks;

  const ReminderScreen({super.key, required this.tasks});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final Map<Calendar, TimeOfDay> _reminders = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: widget.tasks.length,
        itemBuilder: (context, index) {
          final task = widget.tasks[index];
          final reminder = _reminders[task];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(task.title),
              subtitle: Text(
                task.reminderTime != null
                    ? task.reminderTime!.format(context)
                    : 'No reminder set',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.notifications_active),
                onPressed: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    setState(() {
                      _reminders[task] = pickedTime;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Reminder set for ${pickedTime.format(context)}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
