import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/calendar_model.dart';
import 'package:todo_app/models/category_model.dart'; // Needed for category titles
import 'package:todo_app/providers/reminder_count_provider.dart';
import 'package:todo_app/services/notification_service.dart';

class EditCalendarTaskScreen extends StatefulWidget {
  final Calendar task;
  final dynamic hiveKey;

  const EditCalendarTaskScreen({
    required this.task,
    required this.hiveKey,
    Key? key,
  }) : super(key: key);

  @override
  State<EditCalendarTaskScreen> createState() => _EditCalendarTaskScreenState();
}

class _EditCalendarTaskScreenState extends State<EditCalendarTaskScreen> {
  late TextEditingController _titleController;
  late TimeOfDay _selectedTime;
  late String _selectedCategory;

  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _selectedTime = widget.task.reminderTime ?? widget.task.time;
    _selectedCategory = widget.task.category;

    final categoryBox = Hive.box<Category>('categoryBox');

    // Get all category titles from Hive
    final savedTitles = categoryBox.values.map((cat) => cat.title).toSet();

    // Ensure current category is also included (for safety)
    savedTitles.add(_selectedCategory);

    _categories = savedTitles.toList();
  }

  Future<void> _saveChanges() async {
    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      time: _selectedTime,
      category: _selectedCategory,
    );

    final calendarBox = Hive.box<Calendar>('calendarBox');
    await calendarBox.put(widget.hiveKey, updatedTask);

    try {
      // Cancel old notification if it exists
      if (updatedTask.notificationId != null &&
          updatedTask.notificationId! <= 2147483647) {
        if (updatedTask.notificationId != null) {
          await NotificationService.cancelNotification(
            updatedTask.notificationId!,
          );
        }
      }

      // Reschedule notification if reminder exists
      if (updatedTask.parsedReminderTime != null &&
          updatedTask.notificationId! <= 2147483647) {
        final reminder = updatedTask.parsedReminderTime!;
        final scheduledTime = DateTime(
          updatedTask.date.year,
          updatedTask.date.month,
          updatedTask.date.day,
          reminder.hour,
          reminder.minute,
        );

        final success = await NotificationService.scheduleNotification(
          id:
              updatedTask.notificationId ??
              DateTime.now().millisecondsSinceEpoch.remainder(1000000),
          title: updatedTask.title,
          body: 'Reminder for ${updatedTask.title}',
          scheduledTime: scheduledTime,
          category: updatedTask.category,
        );

        if (!success) {
          await calendarBox.put(widget.hiveKey, widget.task); // rollback

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cannot schedule reminder in the past: ${scheduledTime.toLocal()}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(' Reminder set'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Update badge count
        if (mounted) {
          Provider.of<ReminderCountProvider>(
            context,
            listen: false,
          ).updateReminderCount();
        }
      }
    } catch (e) {
      debugPrint("Notification error: $e");
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Edit Task'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Task Title",
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: theme.cardColor,
              ),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time:', style: theme.textTheme.bodyLarge),
                Row(
                  children: [
                    Text(
                      _selectedTime.format(context),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedTime = picked;
                          });
                        }
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text("Change"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Category',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: theme.cardColor,
              ),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
