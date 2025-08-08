// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get tabCategories => 'Категории';

  @override
  String get tabCalendar => 'Календарь';

  @override
  String get tabProfile => 'Профиль';

  @override
  String get editTask => 'Редактировать задачу';

  @override
  String get createTask => 'Создать задачу';

  @override
  String get taskTitle => 'Название задачи';

  @override
  String get enterTitle => 'Введите название';

  @override
  String get category => 'Категория';

  @override
  String get time => 'Время';

  @override
  String get date => 'Дата';

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get saveTask => 'Сохранить задачу';

  @override
  String get noTasksToday => 'Сегодня нет задач';

  @override
  String get upcomingReminders => 'Ближайшие напоминания';

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
  String get noUpcomingReminders => 'Нет предстоящих напоминаний';

  @override
  String get reminderDeleted => 'Напоминание удалено!';

  @override
  String get logout => 'Выйти';

  @override
  String get clearAllData => 'Очистить все данные';

  @override
  String get total => 'Всего';

  @override
  String get completed => 'Выполнено';

  @override
  String get pending => 'В ожидании';

  @override
  String get noCategoriesFound => 'Категории не найдены.\\nСначала создайте категорию.';

  @override
  String get deleteAllTitle => 'Удалить все мои данные';

  @override
  String get deleteAllBody => 'Это безвозвратно удалит ваши задачи и напоминания на этом устройстве. Категории будут сохранены. Это действие нельзя отменить.';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get daily => 'Ежедневно';

  @override
  String get monthly => 'Ежемесячно';

  @override
  String get taskDeleted => 'Задача удалена!';
}
