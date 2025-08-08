// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get tabCategories => '分类';

  @override
  String get tabCalendar => '日历';

  @override
  String get tabProfile => '个人资料';

  @override
  String get editTask => '编辑任务';

  @override
  String get createTask => '创建任务';

  @override
  String get taskTitle => '任务标题';

  @override
  String get enterTitle => '输入标题';

  @override
  String get category => '类别';

  @override
  String get time => '时间';

  @override
  String get date => '日期';

  @override
  String get saveChanges => '保存更改';

  @override
  String get saveTask => '保存任务';

  @override
  String get noTasksToday => '今天没有任务';

  @override
  String get upcomingReminders => '即将到来的提醒';

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
  String get noUpcomingReminders => '暂无即将到来的提醒';

  @override
  String get reminderDeleted => '提醒已删除！';

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
  String get noCategoriesFound => '未找到类别。\\n请先创建一个类别。';

  @override
  String get deleteAllTitle => '删除我的所有数据';

  @override
  String get deleteAllBody => '这将永久删除此设备上的任务和提醒。类别将被保留。此操作无法撤销。';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get daily => '每日';

  @override
  String get monthly => '每月';

  @override
  String get taskDeleted => '任务已删除！';
}
