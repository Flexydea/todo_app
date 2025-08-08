// lib/providers/locale_provider.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;

  static const _key = 'app_locale';
  final _settings = Hive.box('settingsBox');

  LocaleProvider() {
    final saved = _settings.get(_key) as String?;
    if (saved != null) _locale = Locale(saved);
  }

  Future<void> setLocale(String code) async {
    _locale = Locale(code);
    await _settings.put(_key, code);
    notifyListeners();
  }

  // For UI: show native names
  String get readableName {
    const map = {
      'en': 'English',
      'es': 'Español',
      'fr': 'Français',
      'de': 'Deutsch',
      'it': 'Italiano',
      'pt': 'Português',
      'ru': 'Русский',
      'zh': '中文（简体）',
      'ja': '日本語',
      'ar': 'العربية',
      'hi': 'हिन्दी',
    };
    final code = _locale?.languageCode ?? 'en';
    return map[code] ?? 'English';
  }
}
