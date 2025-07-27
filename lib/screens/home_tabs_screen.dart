import 'package:flutter/material.dart';
import 'category_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';

class HomeTabsScreen extends StatefulWidget {
  const HomeTabsScreen({Key? key}) : super(key: key);

  @override
  State<HomeTabsScreen> createState() => _HomeTabsScreenState();
}

class _HomeTabsScreenState extends State<HomeTabsScreen> {
  int _currentIndex = 0;
  String? _selectedCategory;
  List<Widget> get _screens => [
    CategoryScreen(
      onCategoryTap: (selectedCategory) {
        setState(() {
          _selectedCategory = selectedCategory;
          _currentIndex = 1; // Switch to calendar tab
        });
      },
    ),
    CalendarScreen(initialCategory: _selectedCategory),
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
    final List<Widget> _screens = [
      CategoryScreen(
        onCategoryTap: (selectedCategory) {
          setState(() {
            _selectedCategory = selectedCategory;
            _currentIndex = 1; // Switch to calendar tab
          });
        },
      ),
      CalendarScreen(
        initialCategory: _selectedCategory,
        onClearFilter: () {
          setState(() {
            _selectedCategory = null;
          });
        },
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: _currentIndex == 1 && _selectedCategory != null
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedCategory = null; // Clear the category filter
                    _currentIndex = 0; // Switch back to Categories tab
                  });
                },
              )
            : null,
        title: Text(_titles[_currentIndex]),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Optional action
            },
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
