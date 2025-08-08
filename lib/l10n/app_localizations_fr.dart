// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get settings => 'Paramètres';

  @override
  String get statistics => 'Statistiques';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get notificationSettings => 'Notifications';

  @override
  String get language => 'Langue';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get clearAllData => 'Effacer toutes les données';

  @override
  String get total => 'Total';

  @override
  String get completed => 'Terminées';

  @override
  String get pending => 'En attente';

  @override
  String get upcomingReminders => 'Rappels à venir';

  @override
  String get deleteAllTitle => 'Supprimer toutes mes données';

  @override
  String get deleteAllBody => 'Cela supprimera définitivement vos tâches et rappels sur cet appareil. Les catégories seront conservées. Cette action est irréversible.';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';
}
