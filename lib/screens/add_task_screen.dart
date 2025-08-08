import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import 'package:todo_app/models/calendar_model.dart';
import 'package:todo_app/models/category_model.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _selectedCategory = '';
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
      setState(() => _selectedTime = picked);
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
      setState(() => _selectedDate = picked);
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final newTask = Calendar(
        title: _titleController.text,
        time: _selectedTime,
        date: _selectedDate,
        category: _selectedCategory,
        done: false,
        reminderTime: _reminderTime,
        notificationId:
            DateTime.now().millisecondsSinceEpoch.remainder(1000000),
      );

      final _calendarBox = Hive.box<Calendar>('calendarBox');
      _calendarBox.add(newTask);

      Navigator.pop(context, newTask);

      _titleController.clear();
      _selectedTime = TimeOfDay.now();
      _selectedDate = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.createTask),
        backgroundColor: Colors.green,
      ),
      body: _categories.isEmpty
          ? Center(
              child: Text(
                t.noCategoriesFound,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
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
                        labelText: t.taskTitle,
                        labelStyle: theme.textTheme.labelLarge,
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: theme.cardColor,
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? t.enterTitle : null,
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
                              child:
                                  Text(cat, style: theme.textTheme.bodyLarge),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: t.category,
                        labelStyle: theme.textTheme.labelLarge,
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: theme.cardColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(t.time, style: theme.textTheme.bodyLarge),
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
                    Text(t.date, style: theme.textTheme.bodyLarge),
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
                      child: Text(
                        t.saveTask,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
