import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/theme/theme_notifier.dart';
import 'package:todo_app/widgets/account_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Account section at the top
            const AccountSection(),
            const SizedBox(height: 20),
            Text(
              "Statistics",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildStatisticsCards(theme, textTheme),
            const SizedBox(height: 20),
            // Settings
            Text(
              "Settings",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildSettings(context, textTheme),
            const SizedBox(height: 20),
            // Account options
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Account Settings"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Navigate to settings page
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () {
                // TODO: Handle logout logic
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(ThemeData theme, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard(
          "Total tasks",
          "100",
          Icons.show_chart,
          theme,
          textTheme,
        ),
        _buildStatCard(
          "Completed tasks",
          "20",
          Icons.check_circle_outline,
          theme,
          textTheme,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    return Expanded(
      child: Card(
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, style: textTheme.bodyMedium),
              Text(
                value,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettings(BuildContext context, TextTheme textTheme) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return ListTile(
      title: Text("Dark Mode", style: textTheme.bodyMedium),
      trailing: Switch(
        value: themeNotifier.isDarkMode,
        onChanged: (val) => themeNotifier.toggleTheme(val),
      ),
    );
  }
}
