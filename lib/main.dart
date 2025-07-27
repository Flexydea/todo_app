import 'package:flutter/material.dart';
import 'package:todo_app/services/notification_service.dart';
import 'screens/home_tabs_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init(); // initialize notifications
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeTabsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
