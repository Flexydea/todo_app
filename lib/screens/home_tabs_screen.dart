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
import 'package:todo_app/providers/reminder_count_provider.dart';

class HomeTabsScreen extends StatefulWidget {
  const HomeTabsScreen({Key? key}) : super(key: key);

  @override
  State<HomeTabsScreen> createState() => _HomeTabsScreenState();
}

class _HomeTabsScreenState extends State<HomeTabsScreen> {
  int _currentIndex = 0;

  final List<String> _titles = ['Categories', 'Calendar', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final selectedCategory = Provider.of<SelectedCategoryProvider>(
      context,
    ).selectedCategory;

    return Scaffold(
      appBar: AppBar(
        leading: _currentIndex == 1 && selectedCategory != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
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
            child: Consumer<ReminderCountProvider>(
              builder: (context, reminderProvider, _) {
                return badges.Badge(
                  position: badges.BadgePosition.topEnd(top: 0, end: 3),
                  showBadge: reminderProvider.count > 0,
                  badgeContent: Text(
                    reminderProvider.count.toString(),
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

                      // 🔁 Refresh on return
                      Provider.of<ReminderCountProvider>(
                        context,
                        listen: false,
                      ).updateReminderCount();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (_currentIndex == index && index == 1) {
            Provider.of<SelectedCategoryProvider>(
              context,
              listen: false,
            ).clearCategory();
          }
          setState(() {
            _currentIndex = index;
          });
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

  Widget _buildBody() {
    if (_currentIndex == 0) {
      return CategoryScreen(
        onCategoryTap: (selectedCategory) {
          Provider.of<SelectedCategoryProvider>(
            context,
            listen: false,
          ).setCategory(selectedCategory);

          setState(() {
            _currentIndex = 1;
          });
        },
      );
    }

    if (_currentIndex == 1) {
      // Watch the selected category to force rebuild
      return Consumer<SelectedCategoryProvider>(
        builder: (context, provider, _) {
          return CalendarScreen(); // now this rebuilds properly
        },
      );
    }

    return const ProfileScreen();
  }
}
