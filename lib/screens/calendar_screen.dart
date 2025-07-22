import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_app/models/task_model.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class Calendar {
  final String title;
  final DateTime date;
  final TimeOfDay time;

  Calendar({required this.title, required this.date, required this.time});
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool isMonthly = true;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime _selectedDate = DateTime.now();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }
  // Simple Task model

  final List<Calendar> _tasks = [
    Calendar(
      title: 'Meeting with team',
      date: DateTime.now(),
      time: TimeOfDay(hour: 10, minute: 30),
    ),
    Calendar(
      title: 'Buy groceries',
      date: DateTime.now().add(Duration(days: 1)),
      time: TimeOfDay(hour: 17, minute: 0),
    ),
  ];
  // monthly calender picker
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

  // monthly calender picker
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

  // daily picker
  Widget _buildDailyPicker() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 30, // next 30 days
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
                          ? const Color.fromARGB(255, 0, 0, 0)
                          : const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM').format(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? const Color.fromARGB(255, 0, 0, 0)
                          : const Color.fromARGB(255, 0, 0, 0),
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
      return task.date.year == _selectedDate.year &&
          task.date.month == _selectedDate.month &&
          task.date.day == _selectedDate.day;
    }).toList();
    return Column(
      children: [
        // // Toggle
        _buildToggleTabs(),
        isMonthly ? _buildMonthlyCalendar() : _buildDailyPicker(),

        const SizedBox(height: 16),

        const SizedBox(height: 16),

        // Create task button
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.add, color: Color.fromARGB(255, 0, 0, 0)),
            label: const Text(
              'Create new task',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            onPressed: () {
              // TODO: show bottom sheet or form
            },
          ),
        ),

        const SizedBox(height: 16),
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
        // Task list placeholder
        Expanded(
          child: ListView.builder(
            itemCount: tasksForSelectedDate.length,
            itemBuilder: (context, index) {
              final task = tasksForSelectedDate[index];

              return ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text(task.title),
                subtitle: Text(
                  '${task.time.format(context)}',
                ), // ✅ shows time like "10:30 AM"
                trailing: Icon(
                  Icons.star_border,
                ), // Optional icon for later enhancement
              );
            },
          ),
        ),
      ],
    );
  }
}
