import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Add this import

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body with scrollable content
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(), // User avatar and name/email
            const SizedBox(height: 20),

            const Text(
              "Statistics",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),

            _buildStatisticsCards(), // Two stat cards: Total and Completed tasks
            const SizedBox(height: 20),

            const Text(
              "Settings",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),

            _buildSettings(), // Notification, Sound, Language
          ],
        ),
      ),
    );
  }

  // Profile header with avatar, name, and email
  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: const [
          CircleAvatar(
            radius: 40,
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.green,
            ), // Placeholder avatar
          ),
          SizedBox(height: 10),
          Text("John Williams", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
            "johnwilliams@gmail.com",
            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          ),
        ],
      ),
    );
  }

  // Cards showing statistics: total and completed tasks
  Widget _buildStatisticsCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard("Total tasks", "100", Icons.show_chart),
        _buildStatCard("Completed tasks", "20", Icons.check_circle_outline),
      ],
    );
  }

  // Reusable method to build a stat card
  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 32), // Icon at the top
              const SizedBox(height: 8),
              Text(label), // e.g., Total tasks
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ), // e.g., 100
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build each tab item
  Widget _buildProgressTab(String label, {required bool isActive}) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: isActive ? Colors.blue : Colors.white,
        fontSize: 16,
      ),
    );
  }

  // Settings section
  Widget _buildSettings() {
    return Column(
      children: const [
        ListTile(title: Text("Notifications"), trailing: Text("On")),
        ListTile(title: Text("Sound"), trailing: Text("On")),
        ListTile(title: Text("Language"), trailing: Text("English")),
      ],
    );
  }
}

// Static placeholder for Month / Week / Year toggle
class TabBarPlaceholder extends StatelessWidget {
  const TabBarPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Text("Month", style: TextStyle(color: Colors.blue)),
        SizedBox(width: 20),
        Text("Week"),
        SizedBox(width: 20),
        Text("Year"),
      ],
    );
  }
}
