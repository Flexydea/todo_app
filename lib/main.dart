// ignore_for_file: unused_local_variable, dead_code, unused_element, no_leading_underscores_for_local_identifiers
import 'screens/todo_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
// import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  // String _selectedCategory = 'personal'; // Default category

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  void _saveThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
  }

  void _toggleTheme() async {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
  }

  /////////// MY BUILD METHOD /////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      // home: ToDoScreen(isDarkMode: _isDarkMode, onToggleTheme: _toggleTheme),
      home: SplashScreen(isDarkMode: _isDarkMode, onToggleTheme: _toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}

//////////////TO DO SCREEN CLASS//////////////////////////////////////////////////////////

//// _ToDoScreenState class
