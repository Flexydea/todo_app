import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_app/models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/models/calendar_model.dart';
import 'package:todo_app/screens/edit_calendar_task_screen.dart';

class CalendarScreen extends StatefulWidget {
  final String? initialCategory;

  const CalendarScreen({Key? key, this.initialCategory}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    // Apply category filter if passed
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
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

  final List<Calendar> _tasks = [
    Calendar(
      title: 'Meeting with team',
      date: DateTime.now(),
      time: TimeOfDay(hour: 10, minute: 30),
      category: 'Work',
    ),
    Calendar(
      title: 'morning prayer',
      date: DateTime.now(),
      // date: DateTime.now().add(Duration(days: 1)),
      time: TimeOfDay(hour: 17, minute: 0),
      category: 'Personal',
    ),
    Calendar(
      title: 'Afternoon prayer',
      date: DateTime.now(),
      time: TimeOfDay(hour: 17, minute: 0),
      category: 'Shopping',
    ),
    Calendar(
      title: 'Midnight prayer',
      date: DateTime.now(),
      time: TimeOfDay(hour: 17, minute: 0),
      category: 'Urgent',
    ),
  ];

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
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
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
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM').format(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color.fromARGB(255, 0, 0, 0),
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
    final tasksForSelectedDate = _tasks.where((task) {
      final isSameDate =
          task.date.year == _selectedDate.year &&
          task.date.month == _selectedDate.month &&
          task.date.day == _selectedDate.day;

      final matchesCategory =
          widget.initialCategory == null ||
          task.category == widget.initialCategory;

      return isSameDate && matchesCategory;
    }).toList();

    return Column(
      children: [
        _buildToggleTabs(),
        isMonthly ? _buildMonthlyCalendar() : _buildDailyPicker(),
        const SizedBox(height: 40),
        Align(
          alignment: Alignment.center,
          child: Text(
            DateFormat('dd MMM yyyy').format(_selectedDate).toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: tasksForSelectedDate.isEmpty
              ? Center(
                  child: Text(
                    'No tasks today',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: tasksForSelectedDate.length,
                  itemBuilder: (context, index) {
                    final task = tasksForSelectedDate[index];
                    return Dismissible(
                      key: Key('${task.title}-${task.date.toIso8601String()}'),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          _showDeleteAnimation(context);
                          await Future.delayed(
                            const Duration(milliseconds: 600),
                          );
                          setState(() {
                            _tasks.removeAt(index);
                          });
                          return true;
                        } else if (direction == DismissDirection.startToEnd) {
                          setState(() {
                            _tasks[index] = Calendar(
                              title: task.title,
                              date: task.date,
                              time: task.time,
                              done: !task.done,
                              category: task.category,
                            );
                          });
                          return false;
                        }
                        return false;
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: Icon(
                            _categoryIcons[task.category] ?? Icons.label,
                            color: _getCategoryColor(task.category),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.done
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text('${task.time.format(context)}'),
                          onTap: () async {
                            final updatedTask = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditCalendarTaskScreen(
                                  task: task,
                                  onSave: (updatedTask) {
                                    setState(() {
                                      _tasks[index] = updatedTask;
                                    });
                                  },
                                ),
                              ),
                            );

                            if (updatedTask != null) {
                              setState(() {
                                _tasks[index] = updatedTask;
                              });
                            }
                          },
                          trailing: Icon(Icons.notifications),
                        ),
                      ),
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
