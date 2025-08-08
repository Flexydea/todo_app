// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get settings => '设置';

  @override
  String get statistics => '统计';

  @override
  String get darkMode => '深色模式';

  @override
  String get notificationSettings => '通知设置';

  @override
  String get language => '语言';

  @override
  String get logout => '退出登录';

  @override
  String get clearAllData => '清除所有数据';

  @override
  String get total => '总计';

  @override
  String get completed => '已完成';

  @override
  String get pending => '待处理';

  @override
  String get upcomingReminders => '即将到来的提醒';

  @override
  String get deleteAllTitle => '删除我的所有数据';

  @override
  String get deleteAllBody => '这将永久删除此设备上的任务和提醒。分类将被保留。此操作无法撤销。';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';
}
