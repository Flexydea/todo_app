import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:todo_app/theme/theme_notifier.dart';
import 'package:todo_app/widgets/account_section.dart';
import 'package:todo_app/models/calendar_model.dart';
import 'package:todo_app/providers/reminder_count_provider.dart';
import 'package:todo_app/services/notification_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<PackageInfo> _loadAppInfo() => PackageInfo.fromPlatform();

  Future<void> _confirmAndDeleteData(BuildContext context) async {
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: const Text('Delete all my data'),
        content: const Text(
          'This will permanently delete your tasks and reminders on this device. '
          'Categories will be kept. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.15),
              foregroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final calendarBox = Hive.box<Calendar>('calendarBox');
    final remindersBox = Hive.box('remindersBox');

    await calendarBox.clear();
    await remindersBox.clear();
    await NotificationService.cancelAll();

    if (context.mounted) {
      Provider.of<ReminderCountProvider>(
        context,
        listen: false,
      ).updateReminderCount();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'All local data deleted',
            style: TextStyle(
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: theme.brightness == Brightness.dark
              ? Colors.grey[850] // Dark but visible
              : Colors.grey[200], // Light but contrasting
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'OK',
            textColor: theme.colorScheme.primary,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account section
            const AccountSection(),
            const SizedBox(height: 20),

            // Statistics
            Text(
              "Statistics",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _StatisticsRow(),

            const SizedBox(height: 24),

            // Settings
            Text(
              "Settings",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildSettings(context, textTheme),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Notification Settings"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Navigate to a dedicated notification settings page
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Show language picker
              },
            ),
            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () {
                // TODO: Implement logout
              },
            ),

            const SizedBox(height: 8),

            // App info (version/build)
            FutureBuilder<PackageInfo>(
              future: _loadAppInfo(),
              builder: (context, snapshot) {
                final info = snapshot.data;
                final label = info == null
                    ? 'Loading…'
                    : 'Version ${info.version} (${info.buildNumber})';
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      label,
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Clear all data'),
              onTap: () => _confirmAndDeleteData(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettings(BuildContext context, TextTheme textTheme) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Card(
      child: SwitchListTile.adaptive(
        title: Text("Dark Mode", style: textTheme.bodyMedium),
        value: themeNotifier.isDarkMode,
        onChanged: (val) => themeNotifier.toggleTheme(val),
      ),
    );
  }
}

/// Live statistics row (Total tasks / Completed tasks)
class _StatisticsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final box = Hive.box<Calendar>('calendarBox');

    return ValueListenableBuilder<Box<Calendar>>(
      valueListenable: box.listenable(),
      builder: (context, box, _) {
        final tasks = box.values.toList();
        final total = tasks.length;
        final completed = tasks.where((t) => t.done).length;

        return Row(
          children: [
            _StatCard(
              label: "Total",
              value: '$total',
              icon: Icons.list_alt,
              theme: theme,
            ),
            _StatCard(
              label: "Completed",
              value: '$completed',
              icon: Icons.check_circle_outline,
              theme: theme,
            )
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ThemeData theme;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 28, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, style: theme.textTheme.bodyMedium),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
