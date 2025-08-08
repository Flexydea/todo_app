import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/l10n/app_localizations.dart';
import 'package:todo_app/models/calendar_model.dart';
import 'package:todo_app/models/category_model.dart';
import 'package:todo_app/providers/locale_provider.dart';
import 'package:todo_app/providers/profile_photo_provider.dart';
import 'package:todo_app/providers/reminder_count_provider.dart';
import 'package:todo_app/providers/selected_category_provider.dart';
import 'package:todo_app/theme/theme_notifier.dart';
import 'package:todo_app/screens/home_tabs_screen.dart';
import 'adapters/color_adapter.dart';
import 'adapters/icon_data_adapter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'adapters/time_of_day_adapter.dart';

// Make navigatorKey global so it can be used inside services
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  await Hive.initFlutter();

  // Register all adapters before opening boxes
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(CalendarAdapter());
  Hive.registerAdapter(IconDataAdapter());
  Hive.registerAdapter(ColorAdapter());
  Hive.registerAdapter(TimeOfDayAdapter());

  // Remove corrupted box if needed (you already have this)
  // await Hive.deleteBoxFromDisk('calendarBox');

  await Hive.openBox<Category>('categoryBox');
  await Hive.openBox<Calendar>('calendarBox');
  await Hive.openBox('remindersBox');
  await Hive.openBox('settingsBox');

  fixNotificationIds();

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
        ChangeNotifierProvider(
          create: (_) => ReminderCountProvider()..updateReminderCount(),
        ),
        ChangeNotifierProvider(create: (_) => ProfilePhotoProvider()..load()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

void fixNotificationIds() {
  final calendarBox = Hive.box<Calendar>('calendarBox');
  for (var key in calendarBox.keys) {
    final task = calendarBox.get(key);
    if (task != null && task.notificationId! > 2147483647) {
      final updated = task.copyWith(
        notificationId: DateTime.now().millisecondsSinceEpoch.remainder(
              1000000,
            ),
      );
      calendarBox.put(key, updated);
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,

      // Localization settings
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: context.watch<LocaleProvider>().locale,

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
