// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get settings => '設定';

  @override
  String get statistics => '統計';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get notificationSettings => '通知設定';

  @override
  String get language => '言語';

  @override
  String get logout => 'ログアウト';

  @override
  String get clearAllData => 'すべてのデータを削除';

  @override
  String get total => '合計';

  @override
  String get completed => '完了';

  @override
  String get pending => '保留中';

  @override
  String get upcomingReminders => '今後のリマインダー';

  @override
  String get deleteAllTitle => 'すべてのデータを削除';

  @override
  String get deleteAllBody => 'このデバイス上のタスクとリマインダーが完全に削除されます。カテゴリは保持されます。この操作は元に戻せません。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';
}
