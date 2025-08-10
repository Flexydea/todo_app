// lib/screens/auth/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/screens/home_tabs_screen.dart';
import 'package:todo_app/screens/auth/auth_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // settingsBox holds 'currentUser'
    final settingsBox = Hive.box('settingsBox');
    final int? currentUserKey = settingsBox.get('currentUser') as int?;

    if (currentUserKey != null) {
      return const HomeTabsScreen();
    } else {
      return const AuthScreen();
    }
  }
}
