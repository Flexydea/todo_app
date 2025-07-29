import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_app/models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/models/calendar_model.dart';
import 'package:todo_app/screens/edit_calendar_task_screen.dart';
import 'package:todo_app/services/notification_service.dart';
import 'package:todo_app/screens/upcoming_reminders_screen.dart';

class CalendarScreen extends StatefulWidget {
  final List<Calendar> tasks;
  final String? initialCategory;
  final VoidCallback? onClearFilter;
  final VoidCallback? onReminderChanged;

  const CalendarScreen({
    Key? key,
    required this.tasks,
    this.initialCategory,
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

  late List<Calendar> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = widget.tasks;
    _selectedDay = _focusedDay;

    if (widget.initialCategory != null) {
      // Optional: you can filter or highlight based on category
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

  final List<Calendar> tasks = [
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
    final tasksForSelectedDate = _tasks
        .where((task) {
          final isSameDate =
              task.date.year == _selectedDate.year &&
              task.date.month == _selectedDate.month &&
              task.date.day == _selectedDate.day;

          final matchesCategory =
              widget.initialCategory == null ||
              task.category == widget.initialCategory;

          return isSameDate && matchesCategory;
        })
        .toList()
        .reversed
        .toList();

    return Column(
      children: [
        _buildToggleTabs(),
        isMonthly ? _buildMonthlyCalendar() : _buildDailyPicker(),

        const Divider(thickness: 4),
        const SizedBox(height: 40),

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
                        final actualIndex = _tasks.indexOf(
                          task,
                        ); // Get real index

                        if (direction == DismissDirection.endToStart) {
                          final deletedTask =
                              task; // Save the task before deletion

                          _showDeleteAnimation(context);
                          await Future.delayed(
                            const Duration(milliseconds: 600),
                          );

                          setState(() {
                            _tasks.removeAt(actualIndex);

                            // Cancel the system notification
                            NotificationService.cancelNotification(
                              task.notificationId,
                            );

                            // Remove it from upcoming reminders list
                            NotificationService.scheduledReminders.removeWhere(
                              (reminder) =>
                                  reminder['id'] == task.notificationId,
                            );
                            // Trigger parent to update badge
                            if (widget.onReminderChanged != null) {
                              widget.onReminderChanged!();
                            }
                          });
                          // Show SnackBar with Undo
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.black87,
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 20,
                              ),
                              content: const Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.white),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Task deleted',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              duration: const Duration(seconds: 4),
                              action: SnackBarAction(
                                label: 'UNDO',
                                textColor: Colors.green,
                                onPressed: () {
                                  setState(() {
                                    _tasks.insert(actualIndex, deletedTask);
                                  });
                                },
                              ),
                            ),
                          );

                          return true;
                        } else if (direction == DismissDirection.startToEnd) {
                          setState(() {
                            _tasks[actualIndex] = Calendar(
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
                                    final actualIndex = _tasks.indexOf(
                                      task,
                                    ); // ✅ Get real index
                                    if (actualIndex != -1) {
                                      setState(() {
                                        _tasks[actualIndex] = updatedTask;
                                      });

                                      // ✅ Refresh badge if needed
                                      if (widget.onReminderChanged != null) {
                                        widget.onReminderChanged!();
                                      }
                                    }
                                  },
                                ),
                              ),
                            );

                            if (updatedTask != null) {
                              final actualIndex = _tasks.indexOf(
                                task,
                              ); // ✅ Again double-check
                              if (actualIndex != -1) {
                                setState(() {
                                  _tasks[actualIndex] = updatedTask;
                                });

                                // ✅ Also trigger badge refresh here
                                if (widget.onReminderChanged != null) {
                                  widget.onReminderChanged!();
                                }
                              }
                            }
                          },
                          trailing: IconButton(
                            icon: Icon(Icons.notifications),
                            onPressed: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );

                              if (pickedTime != null) {
                                final now = DateTime.now();

                                final scheduledDateTime = DateTime(
                                  task.date.year,
                                  task.date.month,
                                  task.date.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );

                                // Prevent past scheduling
                                if (scheduledDateTime.isBefore(now)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Please pick a future time.',
                                      ),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                                final notificationId = DateTime.now()
                                    .millisecondsSinceEpoch
                                    .remainder(100000);

                                await NotificationService.scheduleNotification(
                                  id: notificationId,
                                  title: 'Task Reminder',
                                  body: task.title,
                                  scheduledTime: scheduledDateTime,
                                  category: task.category,
                                );

                                // Update your task with notificationId
                                final updatedTask = task.copyWith(
                                  reminderTime: pickedTime,
                                  notificationId: notificationId,
                                );

                                setState(() {
                                  final index = _tasks.indexOf(task);
                                  if (index != -1) {
                                    _tasks[index] = updatedTask;

                                    // Also update the original task list to avoid stale data
                                    final widgetIndex = widget.tasks.indexOf(
                                      task,
                                    );
                                    if (widgetIndex != -1) {
                                      widget.tasks[widgetIndex] = updatedTask;
                                    }
                                  }

                                  // ✅ Notify parent if needed (for upcoming reminders screen or badge refresh)
                                  if (widget.onReminderChanged != null) {
                                    widget.onReminderChanged!();
                                  }
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.black87,
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 20,
                                    ),
                                    content: Row(
                                      children: [
                                        const Icon(
                                          Icons.notifications_active,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Reminder set for ${pickedTime.format(context)}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
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
