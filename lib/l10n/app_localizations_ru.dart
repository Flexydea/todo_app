// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get settings => 'Настройки';

  @override
  String get statistics => 'Статистика';

  @override
  String get darkMode => 'Тёмная тема';

  @override
  String get notificationSettings => 'Уведомления';

  @override
  String get language => 'Язык';

  @override
  String get logout => 'Выйти';

  @override
  String get clearAllData => 'Удалить все данные';

  @override
  String get total => 'Всего';

  @override
  String get completed => 'Выполнено';

  @override
  String get pending => 'В ожидании';

  @override
  String get upcomingReminders => 'Ближайшие напоминания';

  @override
  String get deleteAllTitle => 'Удалить все мои данные';

  @override
  String get deleteAllBody => 'Это навсегда удалит ваши задачи и напоминания на этом устройстве. Категории будут сохранены. Это действие нельзя отменить.';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';
}
