import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:todo_app/l10n/app_localizations.dart';

// Models & adapters
import 'package:todo_app/models/calendar_model.dart';
import 'package:todo_app/models/category_model.dart';
import 'package:todo_app/models/user_model.dart';
import 'adapters/color_adapter.dart';
import 'adapters/icon_data_adapter.dart';
import 'adapters/time_of_day_adapter.dart';

// Providers
import 'package:todo_app/providers/locale_provider.dart';
import 'package:todo_app/providers/profile_photo_provider.dart';
import 'package:todo_app/providers/reminder_count_provider.dart';
import 'package:todo_app/providers/selected_category_provider.dart';
import 'package:todo_app/theme/theme_notifier.dart';

// Screens
import 'package:todo_app/screens/home_tabs_screen.dart';
import 'package:todo_app/screens/auth/auth_screen.dart';

// Timezone
import 'package:timezone/data/latest.dart' as tz;

// Global navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  await Hive.initFlutter();

  // Register adapters BEFORE opening boxes
  Hive
    ..registerAdapter(CategoryAdapter())
    ..registerAdapter(CalendarAdapter())
    ..registerAdapter(IconDataAdapter())
    ..registerAdapter(ColorAdapter())
    ..registerAdapter(TimeOfDayAdapter())
    ..registerAdapter(UserAdapter());

  await Hive.openBox<Category>('categoryBox');
  await Hive.openBox<Calendar>('calendarBox');
  await Hive.openBox('remindersBox');
  await Hive.openBox('settingsBox');
  await Hive.openBox<User>('userBox');
  await Hive.openBox('profilePhotosBox');

  _fixNotificationIds();

  // Seed categories on first run
  final categoryBox = Hive.box<Category>('categoryBox');
  if (categoryBox.isEmpty) {
    categoryBox.addAll([
      Category(title: 'Work', icon: Icons.work, color: Colors.blue),
      Category(title: 'Personal', icon: Icons.person, color: Colors.purple),
      Category(
          title: 'Shopping', icon: Icons.shopping_cart, color: Colors.orange),
      Category(title: 'Urgent', icon: Icons.warning, color: Colors.red),
    ]);
  }

  // Check auth state
  final userBox = Hive.box<User>('userBox');
  final hasUser = userBox.get('currentUser') != null;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => SelectedCategoryProvider()),
        ChangeNotifierProvider(
            create: (_) => ReminderCountProvider()..updateReminderCount()),
        ChangeNotifierProvider(
            create: (_) => ProfilePhotoProvider()..loadForCurrentUser()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: MyApp(isLoggedIn: hasUser),
    ),
  );
}

void _fixNotificationIds() {
  final calendarBox = Hive.box<Calendar>('calendarBox');
  for (final key in calendarBox.keys) {
    final task = calendarBox.get(key);
    if (task == null) continue;
    final nid = task.notificationId;
    if (nid != null && nid > 2147483647) {
      final updated = task.copyWith(
        notificationId:
            DateTime.now().millisecondsSinceEpoch.remainder(1000000),
      );
      calendarBox.put(key, updated);
    }
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final localeProvider = context.watch<LocaleProvider>();

// Pull session flag from Hive. We stored an int user key at 'currentUser'.
    //    If it exists, the user is logged in and we start at /home, else /auth.
    final settingsBox = Hive.box('settingsBox');
    final bool isLoggedIn = settingsBox.get('currentUser') != null;

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,

      //  Localization
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localeProvider.locale,

      //  Theme
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.black)),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[900],
        textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.white)),
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green, brightness: Brightness.dark),
      ),

      //  Routing
      initialRoute: isLoggedIn ? '/home' : '/auth',
      routes: {
        '/home': (_) => const HomeTabsScreen(),
        '/auth': (_) => const AuthScreen(),
      },
    );
  }
}
