// screens/alerts_screen.dart
import 'package:flutter/material.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Alerts',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // List of Alerts
            _buildAlertItem(
              title: 'Time to Run!',
              subtitle: 'You have 30 min scheduled for running today.',
              time: 'Just now',
              isUnread: true,
            ),
            const SizedBox(height: 15),
            _buildAlertItem(
              title: 'Weekly Goal Reached!',
              subtitle: 'You’ve completed 75% of your weekly goal.',
              time: 'Yesterday, 18:30',
              isUnread: false,
            ),
            const SizedBox(height: 15),
            _buildAlertItem(
              title: 'Hydration Reminder',
              subtitle: 'Don’t forget to drink water every hour!',
              time: 'Oct 10, 10:00',
              isUnread: false,
            ),
            const SizedBox(height: 15),
            _buildAlertItem(
              title: 'New Achievement Unlocked',
              subtitle: 'You’ve run 100 km this month!',
              time: 'Oct 9, 09:00',
              isUnread: true,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Simulasi tambah alert
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Add new alert!')));
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAlertItem({
    required String title,
    required String subtitle,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread
            ? Colors.blue.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: isUnread
            ? Border.all(color: Colors.blue.withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnread
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
            ),
            child: Icon(
              Icons.notifications,
              color: isUnread ? Colors.blue : Colors.grey[700],
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isUnread ? Colors.blue : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          if (isUnread)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
        ],
      ),
    );
  }
}
