import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/calendar_model.dart';
import 'package:todo_app/models/category_model.dart';
import 'package:todo_app/providers/selected_category_provider.dart';
import 'package:todo_app/theme/theme_notifier.dart';
import 'package:todo_app/screens/home_tabs_screen.dart';
import 'adapters/color_adapter.dart';
import 'adapters/icon_data_adapter.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.deleteBoxFromDisk('calendarBox');
  await Hive.openBox<Calendar>('calendarBox');
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(CalendarAdapter());
  Hive.registerAdapter(IconDataAdapter());
  Hive.registerAdapter(ColorAdapter());

  await Hive.openBox<Category>('categoryBox');
  await Hive.openBox<Calendar>('calendarBox');

  final categoryBox = Hive.box<Category>('categoryBox');
  if (categoryBox.isEmpty) {
    categoryBox.addAll([
      Category(title: 'Work', icon: Icons.work, color: Colors.blue),
      Category(title: 'Personal', icon: Icons.person, color: Colors.purple),
      Category(
        title: 'Shopping',
        icon: Icons.shopping_cart,
        color: Colors.orange,
      ),
      Category(title: 'Urgent', icon: Icons.warning, color: Colors.red),
    ]);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => SelectedCategoryProvider()),
      ],
      child: const MyApp(), // ✅ this must come after class MyApp is defined
    ),
  );
}
