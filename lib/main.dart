import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/services/notification_service.dart';
import 'theme/theme_notifier.dart';
import 'screens/home_tabs_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.black)),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[900],
        textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.white)),
      ),
      home: const HomeTabsScreen(),
    );
  }
}
