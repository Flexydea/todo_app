import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

import 'package:todo_app/providers/selected_category_provider.dart';
import 'package:todo_app/providers/reminder_count_provider.dart';
import 'package:todo_app/screens/upcoming_reminders_screen.dart';
import 'package:todo_app/screens/category_screen.dart';
import 'package:todo_app/screens/calendar_screen.dart'
    hide UpcomingRemindersScreen;
import 'package:todo_app/screens/profile_screen.dart';
import 'package:todo_app/l10n/app_localizations.dart';

class HomeTabsScreen extends StatefulWidget {
  const HomeTabsScreen({Key? key}) : super(key: key);

  @override
  State<HomeTabsScreen> createState() => _HomeTabsScreenState();
}

class _HomeTabsScreenState extends State<HomeTabsScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final titles = [t.tabCategories, t.tabCalendar, t.tabProfile];

    final selectedCategory =
        context.watch<SelectedCategoryProvider>().selectedCategory;

    return Scaffold(
      appBar: AppBar(
        leading: _currentIndex == 1 && selectedCategory != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.read<SelectedCategoryProvider>().clearCategory();
                  setState(() => _currentIndex = 0);
                },
              )
            : null,
        title: Text(titles[_currentIndex]),
        backgroundColor: Colors.green,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Consumer<ReminderCountProvider>(
              builder: (_, reminderProvider, __) {
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
                          builder: (_) => const UpcomingRemindersScreen(),
                        ),
                      );
                      // refresh badge after returning
                      context
                          .read<ReminderCountProvider>()
                          .updateReminderCount();
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
            context.read<SelectedCategoryProvider>().clearCategory();
          }
          setState(() => _currentIndex = index);
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: t.tabCategories,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today),
            label: t.tabCalendar,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: t.tabProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 0) {
      return CategoryScreen(
        onCategoryTap: (selectedCategory) {
          context
              .read<SelectedCategoryProvider>()
              .setCategory(selectedCategory);
          setState(() => _currentIndex = 1);
        },
      );
    }

    // lib/screens/home_tabs_screen.dart
    if (_currentIndex == 1) {
      return Consumer<SelectedCategoryProvider>(
        builder: (_, __, ___) => CalendarScreen(), // ← remove const
      );
    }

    return const ProfileScreen();
  }
}
