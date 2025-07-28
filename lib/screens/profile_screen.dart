import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/theme/theme_notifier.dart';

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(textTheme),
            const SizedBox(height: 20),

            Text(
              "Statistics",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            _buildStatisticsCards(theme, textTheme),
            const SizedBox(height: 20),

            Text(
              "Settings",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            _buildSettings(context, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(TextTheme textTheme) {
    return Center(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            child: Icon(Icons.person, size: 40, color: Colors.green),
          ),
          const SizedBox(height: 10),
          Text(
            "John Williams",
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text("johnwilliams@gmail.com", style: textTheme.bodySmall),
        ],
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

    return Column(
      children: [
        ListTile(
          title: Text("Dark Mode", style: textTheme.bodyMedium),
          trailing: Switch(
            value: themeNotifier.isDarkMode,
            onChanged: (val) => themeNotifier.toggleTheme(val),
          ),
        ),
        ListTile(
          title: Text("Notifications", style: textTheme.bodyMedium),
          trailing: Text("On", style: textTheme.bodySmall),
        ),
        ListTile(
          title: Text("Sound", style: textTheme.bodyMedium),
          trailing: Text("On", style: textTheme.bodySmall),
        ),
        ListTile(
          title: Text("Language", style: textTheme.bodyMedium),
          trailing: Text("English", style: textTheme.bodySmall),
        ),
      ],
    );
  }
}
