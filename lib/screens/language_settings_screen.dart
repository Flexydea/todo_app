// lib/screens/language_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:todo_app/l10n/app_localizations.dart';
import 'package:todo_app/providers/locale_provider.dart';
import 'package:todo_app/l10n/app_localizations.dart';

class LanguageSettingsScreen extends StatelessWidget {
  LanguageSettingsScreen({super.key});

  // Show native names so users recognize their language quickly
  final Map<String, String> _languages = const {
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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final provider = context.watch<LocaleProvider>();
    final current = provider.locale?.languageCode ?? 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(t.language),
        backgroundColor: Colors.green,
      ),
      body: ListView.separated(
        itemCount: _languages.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final code = _languages.keys.elementAt(index);
          final name = _languages[code]!;
          final selected = code == current;

          return RadioListTile<String>(
            value: code,
            groupValue: current,
            title: Text(name),
            activeColor: Colors.green,
            onChanged: (val) async {
              if (val == null) return;
              await provider.setLocale(val);

              final isDark = theme.brightness == Brightness.dark;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${t.language}: $name',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: isDark ? Colors.grey[850] : Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
