import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/models/calendar_model.dart';
import 'package:todo_app/providers/selected_category_provider.dart';
import 'package:todo_app/screens/edit_calendar_task_screen.dart';
import 'package:todo_app/services/notification_service.dart';
import 'package:todo_app/screens/upcoming_reminders_screen.dart';
import 'package:todo_app/widgets/task_card.dart';

class CalendarScreen extends StatefulWidget {
  // final List<Calendar> tasks;
  // final String? initialCategory;
  final VoidCallback? onClearFilter;
  final VoidCallback? onReminderChanged;

  const CalendarScreen({
    Key? key,
    // required this.tasks,
    // this.initialCategory,
    this.onClearFilter,
    this.onReminderChanged,
  }) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool isMonthly = true;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime _selectedDate = DateTime.now();
  DateTime selectedDate = DateTime.now();

  late String _filteredCategory;

  late Box<Calendar> _calendarBox;

  @override
  void initState() {
    super.initState();
    _calendarBox = Hive.box<Calendar>('calendarBox');
  }

  String? _selectedCategory;

  void _showDeleteAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.grey,
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
                'Task deleted!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  final Map<String, IconData> _categoryIcons = {
    'Work': Icons.work,
    'Personal': Icons.person,
    'Shopping': Icons.shopping_cart,
    'Urgent': Icons.warning,
  };

  Widget _buildToggleTabs() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isMonthly = false;
                });
              },
              child: Container(
                color: !isMonthly ? Colors.green : Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  'DAILY',
                  style: TextStyle(
                    color: !isMonthly ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isMonthly = true;
                });
              },
              child: Container(
                color: isMonthly ? Colors.green : Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  'MONTHLY',
                  style: TextStyle(
                    color: isMonthly ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyCalendar() {
    return TableCalendar(
      focusedDay: _selectedDate,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
      onDaySelected: (selectedDay, _) {
        setState(() => _selectedDate = selectedDay);
      },
      calendarStyle: CalendarStyle(
        todayDecoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        outsideTextStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors
                    .white54 // Light grey in dark mode
              : Colors.grey[500],
        ),
        defaultTextStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        weekendTextStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white70
              : Colors.black87,
        ),
      ),
      headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true),
    );
  }

  Widget _buildDailyPicker() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 30,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected =
              _selectedDate.year == date.year &&
              _selectedDate.month == date.month &&
              _selectedDate.day == date.day;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color.fromARGB(255, 0, 0, 0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('dd').format(date),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM').format(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = Provider.of<SelectedCategoryProvider>(
      context,
    ).selectedCategory;

    return Column(
      children: [
        _buildToggleTabs(),
        isMonthly ? _buildMonthlyCalendar() : _buildDailyPicker(),

        const Divider(thickness: 4),
        const SizedBox(height: 12),

        Align(
          alignment: Alignment.center,
          child: Text(
            DateFormat('dd MMM yyyy').format(_selectedDate).toUpperCase(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: Consumer<SelectedCategoryProvider>(
            builder: (context, provider, _) {
              final selectedCategory = provider.selectedCategory;

              return ValueListenableBuilder<Box<Calendar>>(
                valueListenable: _calendarBox.listenable(),
                builder: (context, box, _) {
                  final tasksForDate = box.keys
                      .where((key) {
                        final task = box.get(key)!;

                        final matchesDate =
                            task.date.year == _selectedDate.year &&
                            task.date.month == _selectedDate.month &&
                            task.date.day == _selectedDate.day;

                        final matchesCategory =
                            selectedCategory == null ||
                            task.category.trim().toLowerCase() ==
                                selectedCategory.trim().toLowerCase();

                        return matchesDate && matchesCategory;
                      })
                      .map((key) => MapEntry(key, box.get(key)!))
                      .toList();

                  if (tasksForDate.isEmpty) {
                    return const Center(
                      child: Text(
                        'No tasks today',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: tasksForDate.length,
                    itemBuilder: (_, index) {
                      final entry = tasksForDate[index];
                      return TaskCard(task: entry.value, hiveKey: entry.key);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Colors.blue;
      case 'personal':
        return Colors.orange;
      case 'shopping':
        return Colors.green;
      case 'urgent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
