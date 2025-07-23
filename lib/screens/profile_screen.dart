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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _buildStatisticsCards(), // Two stat cards: Total and Completed tasks
            const SizedBox(height: 20),

            const Text(
              "Your progress",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _buildProgressSection(), // Chart placeholder and tab
            const SizedBox(height: 20),

            const Text(
              "Settings",
              style: TextStyle(fontWeight: FontWeight.bold),
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

  // Tab selector above the chart
  Widget _buildProgressTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildProgressTab('Month', isActive: false),
        const SizedBox(width: 16),
        _buildProgressTab('Week', isActive: false),
        const SizedBox(width: 16),
        _buildProgressTab('Year', isActive: true), // currently active
      ],
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

  // Progress chart section
  // This widget builds the progress section in the profile screen
  // It includes a tab placeholder (Month, Week, Year) and a line chart
  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TabBarPlaceholder(), // Month / Week / Year tabs
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, _) {
                      switch (value.toInt()) {
                        case 0:
                          return const Text(
                            'May',
                            style: TextStyle(color: Colors.white),
                          );
                        case 1:
                          return const Text(
                            'Jun',
                            style: TextStyle(color: Colors.white),
                          );
                        case 2:
                          return const Text(
                            'Jul',
                            style: TextStyle(color: Colors.white),
                          );
                        case 3:
                          return const Text(
                            'Aug',
                            style: TextStyle(color: Colors.white),
                          );
                        case 4:
                          return const Text(
                            'Sep',
                            style: TextStyle(color: Colors.white),
                          );
                        case 5:
                          return const Text(
                            'Oct',
                            style: TextStyle(color: Colors.white),
                          );
                        case 6:
                          return const Text(
                            'Nov',
                            style: TextStyle(color: Colors.white),
                          );
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, _) =>
                        spot.x == 2, // Show dot only on July
                    getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                      radius: 6,
                      color: Colors.black,
                      strokeWidth: 3,
                      strokeColor: Colors.black,
                    ),
                  ),
                  belowBarData: BarAreaData(show: false),
                  spots: const [
                    FlSpot(0, 20),
                    FlSpot(1, 20),
                    FlSpot(2, 30), // highlighted
                    FlSpot(3, 45),
                    FlSpot(4, 40),
                    FlSpot(5, 35),
                    FlSpot(6, 30),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
