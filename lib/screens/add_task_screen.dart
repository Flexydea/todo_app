import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/models/calendar_model.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/models/category_model.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _selectedCategory = 'Work';
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _reminderTime;

  late List<String> _categories;

  @override
  void initState() {
    super.initState();

    final Box<Category> categoryBox = Hive.box<Category>('categoryBox');
    _categories = categoryBox.values.map((e) => e.title).toList();

    if (_categories.isNotEmpty) {
      _selectedCategory = _categories.first;
    }
  }

  void _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final newTask = Calendar(
        title: _titleController.text,
        time: _selectedTime,
        date: _selectedDate,
        category:
            _selectedCategory, // Make sure you're assigning the selected category
        done: false, // default to not done
        reminderTime: _reminderTime,
        notificationId: DateTime.now().millisecondsSinceEpoch.remainder(
          1000000,
        ),
      );

      final calendarBox = Hive.box<Calendar>('calendarBox');
      calendarBox.add(newTask); // This saves the task to Hive

      Navigator.pop(context, newTask); // Pass back to the previous screen

      // Reset form
      _titleController.clear();
      _selectedTime = TimeOfDay.now();
      _selectedDate = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
        backgroundColor: Colors.green,
      ),
      body: _categories.isEmpty
          ? const Center(
              child: Text(
                'No categories found.\nPlease create a category first.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 16),
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
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter a title'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      style: theme.textTheme.bodyLarge,
                      dropdownColor: theme.cardColor,
                      items: _categories
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(
                                cat,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: theme.textTheme.labelLarge,
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: theme.cardColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Time', style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _pickTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedTime.format(context),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Date', style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat.yMMMd().format(_selectedDate),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Save Task',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
