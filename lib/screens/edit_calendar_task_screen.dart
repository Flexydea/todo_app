import 'package:flutter/material.dart';
import 'package:todo_app/models/calendar_model.dart';

class EditCalendarTaskScreen extends StatefulWidget {
  final Calendar task;
  final void Function(Calendar updatedTask) onSave;

  const EditCalendarTaskScreen({
    required this.task,
    required this.onSave,
    Key? key,
  }) : super(key: key);

  @override
  State<EditCalendarTaskScreen> createState() => _EditCalendarTaskScreenState();
}

class _EditCalendarTaskScreenState extends State<EditCalendarTaskScreen> {
  late TextEditingController _titleController;
  late TimeOfDay _selectedTime;
  late String _selectedCategory;

  final List<String> _categories = ['Work', 'Personal', 'Shopping', 'Urgent'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _selectedTime = widget.task.time;
    _selectedCategory = widget.task.category;
  }

  void _saveChanges() {
    final updatedTask = Calendar(
      title: _titleController.text,
      date: widget.task.date,
      time: _selectedTime,
      category: _selectedCategory,
      done: widget.task.done,
    );
    widget.onSave(updatedTask);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Edit Task'),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: "Task Title",
                labelStyle: theme.textTheme.labelLarge,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: theme.cardColor,
              ),
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
              style: theme.textTheme.bodyLarge,
              dropdownColor: theme.cardColor,
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: theme.textTheme.labelLarge,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: theme.cardColor,
              ),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                child: const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
