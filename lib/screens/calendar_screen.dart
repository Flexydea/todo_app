import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'package:todo_app/models/calendar_model.dart';
import 'package:todo_app/providers/selected_category_provider.dart';
import 'package:todo_app/widgets/task_card.dart';
import 'package:todo_app/l10n/app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  final VoidCallback? onClearFilter;
  final VoidCallback? onReminderChanged;

  const CalendarScreen({Key? key, this.onClearFilter, this.onReminderChanged})
      : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with TickerProviderStateMixin {
  bool isMonthly = true;
  DateTime _selectedDate = DateTime.now();
  late Box<Calendar> _calendarBox;

  @override
  void initState() {
    super.initState();
    _calendarBox = Hive.box<Calendar>('calendarBox');
    _selectedDate = DateTime.now();
    // tiny delay gives Hive/Provider time to settle after hot reloads
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) setState(() {});
    });
  }

  void _showDeleteAnimation(BuildContext context) {
    // NOTE: If you want this text localized, add "taskDeleted" to your ARB files.
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
                'Task deleted!', // TODO: localize if you add "taskDeleted"
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

  Widget _buildToggleTabs(BuildContext context) {
    // TODO: Add "daily" and "monthly" to your ARB files if you want these localized.
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
              onTap: () => setState(() => isMonthly = false),
              child: Container(
                color: !isMonthly ? Colors.green : Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  'DAILY', // t.daily (once added)
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
              onTap: () => setState(() => isMonthly = true),
              child: Container(
                color: isMonthly ? Colors.green : Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  'MONTHLY', // t.monthly (once added)
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
    return ValueListenableBuilder(
      valueListenable: _calendarBox.listenable(),
      builder: (context, Box<Calendar> box, _) {
        return TableCalendar(
          focusedDay: _selectedDate,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
          onDaySelected: (selectedDay, _) {
            setState(() {
              _selectedDate = selectedDay;
              isMonthly = false; // auto switch to daily after selecting a day
            });
          },
          eventLoader: (day) {
            return box.values
                .where((task) => isSameDay(task.date, day))
                .toList();
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
            markerDecoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 1,
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        );
      },
    );
  }

  Widget _buildDailyPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 30,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = isSameDay(_selectedDate, date);

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('dd', Localizations.localeOf(context).toString())
                        .format(date),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : isDark
                              ? Colors.white70
                              : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat(
                            'MMM', Localizations.localeOf(context).toString())
                        .format(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white
                          : isDark
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
    final t = AppLocalizations.of(context)!;
    final selectedCategory =
        context.watch<SelectedCategoryProvider>().selectedCategory;

    // Localized date label (e.g., “10 Aug 2025”) in current locale
    final localeName = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat('dd MMM yyyy', localeName)
        .format(_selectedDate)
        .toUpperCase();

    return Column(
      children: [
        _buildToggleTabs(context),
        isMonthly ? _buildMonthlyCalendar() : _buildDailyPicker(context),
        const Divider(thickness: 4),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.center,
          child: Text(
            dateLabel,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ValueListenableBuilder<Box<Calendar>>(
            valueListenable: _calendarBox.listenable(),
            builder: (context, box, _) {
              final selectedDate = _selectedDate;

              final tasksForDate = box.keys
                  .where((key) {
                    final task = box.get(key);
                    if (task == null) return false;

                    final matchesDate = isSameDay(task.date, selectedDate);

                    final matchesCategory = selectedCategory == null ||
                        task.category.trim().toLowerCase() ==
                            selectedCategory.trim().toLowerCase();

                    return matchesDate && matchesCategory;
                  })
                  .map((key) => MapEntry(key, box.get(key)!))
                  .toList()
                ..sort((a, b) => a.value.time.compareTo(b.value.time));

              if (tasksForDate.isEmpty) {
                return Center(
                  child: Text(
                    t.noTasksToday, // ← localized
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
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
          ),
        ),
      ],
    );
  }
}
