import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/calendar_model.dart';
import 'package:todo_app/providers/selected_category_provider.dart';
import 'package:todo_app/screens/upcoming_reminders_screen.dart';
import 'category_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import 'package:badges/badges.dart' as badges;
import 'package:todo_app/services/notification_service.dart';
import 'package:todo_app/screens/upcoming_reminders_screen.dart';

class HomeTabsScreen extends StatefulWidget {
  const HomeTabsScreen({Key? key}) : super(key: key);

  @override
  State<HomeTabsScreen> createState() => _HomeTabsScreenState();
}

class _HomeTabsScreenState extends State<HomeTabsScreen> {
  int _currentIndex = 0;
  String? _selectedCategory;
  late Box<Calendar> _calendarBox;

  @override
  void initState() {
    super.initState();
    _calendarBox = Hive.box<Calendar>('calendarBox');
  }

  // // ✅ Task list
  // final List<Calendar> _tasks = [
  //   Calendar(
  //     title: 'Meeting with team',
  //     date: DateTime.now(),
  //     time: TimeOfDay(hour: 10, minute: 30),
  //     category: 'Work',
  //   ),
  //   Calendar(
  //     title: 'morning prayer',
  //     date: DateTime.now(),
  //     time: TimeOfDay(hour: 17, minute: 0),
  //     category: 'Personal',
  //   ),
  //   Calendar(
  //     title: 'Afternoon prayer',
  //     date: DateTime.now(),
  //     time: TimeOfDay(hour: 17, minute: 0),
  //     category: 'Shopping',
  //   ),
  //   Calendar(
  //     title: 'Midnight prayer',
  //     date: DateTime.now(),
  //     time: TimeOfDay(hour: 17, minute: 0),
  //     category: 'Urgent',
  //   ),
  // ];

  List<Widget> get _screens => [
    CategoryScreen(
      onCategoryTap: (selectedCategory) {
        Provider.of<SelectedCategoryProvider>(
          context,
          listen: false,
        ).setCategory(selectedCategory);

        setState(() {
          _currentIndex = 1;
        });
      },
    ),
    CalendarScreen(
      tasks: _calendarBox.values.toList(),
      initialCategory: _selectedCategory,
      onClearFilter: () {
        setState(() {
          _selectedCategory = null;
        });
      },
      onReminderChanged: () {
        setState(() {});
      },
    ),
    const ProfileScreen(),
  ];

  void _handleCategoryTap(String category) {
    setState(() {
      _selectedCategory = category;
      _currentIndex = 1;
    });
  }

  final List<String> _titles = ['Categories', 'Calendar', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:
            _currentIndex == 1 &&
                Provider.of<SelectedCategoryProvider>(
                      context,
                    ).selectedCategory !=
                    null
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Provider.of<SelectedCategoryProvider>(
                    context,
                    listen: false,
                  ).clearCategory();
                  setState(() {
                    _currentIndex = 0;
                  });
                },
              )
            : null,
        title: Text(_titles[_currentIndex]),
        backgroundColor: Colors.green,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: badges.Badge(
              position: badges.BadgePosition.topEnd(top: 0, end: 3),
              showBadge: NotificationService.scheduledReminders.isNotEmpty,
              badgeContent: Text(
                NotificationService.scheduledReminders.length.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Colors.red,
                padding: EdgeInsets.all(6),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UpcomingRemindersScreen(),
                    ),
                  );
                  setState(() {}); // Refresh badge when returning
                },
              ),
            ),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (_currentIndex == index &&
              index == 1 &&
              _selectedCategory != null) {
            // Calendar tab re-tapped while filter is active
            setState(() {
              _selectedCategory = null; // Clear filter
            });
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
