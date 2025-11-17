// screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.1),
              ),
              child: Icon(Icons.settings, color: Colors.blue, size: 70),
            ),
            const SizedBox(height: 10),
            const Text(
              'Settings',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            // === Account ===
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: const Icon(Icons.person, color: Colors.blue),
              ),
              title: const Text('Account'),
              subtitle: const Text('Manage your profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            // === My Stats ===
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: const Icon(Icons.bar_chart, color: Colors.green),
              ),
              title: const Text('My Stats'),
              subtitle: const Text('View your daily & weekly stats'),
              onTap: () {
                _showStatsDialog(context);
              },
            ),
            const Divider(),
            // === Reminders ===
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: const Icon(Icons.alarm, color: Colors.orange),
              ),
              title: const Text('Reminders'),
              subtitle: const Text('Set workout time reminders'),
              onTap: () {
                _showRemindersDialog(context);
              },
            ),
            const Divider(),
            // === Goals ===
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: const Icon(Icons.flag, color: Colors.red),
              ),
              title: const Text('Goals'),
              subtitle: const Text('Track your weekly targets'),
              onTap: () {
                _showGoalsDialog(context);
              },
            ),
            const Divider(),
            // === Security ===
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: const Icon(Icons.security, color: Colors.purple),
              ),
              title: const Text('Security'),
              subtitle: const Text('Change password & verify email'),
              onTap: () {
                _showSecurityDialog(context);
              },
            ),
            const Divider(),
            // === Dark Mode ===
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: const Icon(Icons.dark_mode, color: Colors.grey),
              ),
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle dark/light theme'),
              trailing: Switch(
                value: false, // Ganti dengan state tema
                onChanged: (value) {},
                activeColor: Colors.orange,
              ),
              onTap: () {
                // Toggle theme
              },
            ),
            const Divider(),
            // === Terms of Service ===
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: const Icon(Icons.description, color: Colors.teal),
              ),
              title: const Text('Terms of Service'),
              subtitle: const Text('Read our terms & conditions'),
              onTap: () {
                _showTermsDialog(context);
              },
            ),
            const Divider(),
            // === Contact Us ===
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: const Icon(Icons.email, color: Colors.indigo),
              ),
              title: const Text('Contact Us'),
              subtitle: const Text('Reach out for support'),
              onTap: () {
                _showContactDialog(context);
              },
            ),
            const Divider(),
            // === Export Data ===
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: const Icon(Icons.download, color: Colors.blue),
              ),
              title: const Text('Export Data'),
              subtitle: const Text('Download your workout history'),
              onTap: () {
                _showExportDialog(context);
              },
            ),
            const Divider(),
            // === Logout ===
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: const Icon(Icons.exit_to_app, color: Colors.red),
              ),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              subtitle: const Text('Sign out from your account'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('My Stats'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatCard('Total Workouts', '24', Colors.green),
              const SizedBox(height: 10),
              _buildStatCard('Total Distance', '125.6 km', Colors.blue),
              const SizedBox(height: 10),
              _buildStatCard('Calories Burned', '12,450 cal', Colors.orange),
              const SizedBox(height: 10),
              _buildStatCard('Weekly Goal', '75% Completed', Colors.purple),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(Icons.bar_chart, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(color: color, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRemindersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Workout Reminders'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildReminderOption('Morning Run', '7:00 AM', true),
              const SizedBox(height: 10),
              _buildReminderOption('Evening Walk', '6:00 PM', false),
              const SizedBox(height: 10),
              _buildReminderOption('Weekend Hike', '9:00 AM', true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReminderOption(String title, String time, bool enabled) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: (value) {},
            activeColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  void _showGoalsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Weekly Goals'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGoalCard('Run 50 km', '25 km done', Colors.green),
              const SizedBox(height: 10),
              _buildGoalCard(
                'Walk 100,000 steps',
                '65,000 steps done',
                Colors.blue,
              ),
              const SizedBox(height: 10),
              _buildGoalCard(
                'Burn 5,000 calories',
                '3,200 calories burned',
                Colors.orange,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGoalCard(String title, String progress, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.65, // Ganti dengan nilai dinamis
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 8),
          Text(progress, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  void _showSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Security Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSecurityOption('Change Password', Icons.lock, Colors.blue),
              const SizedBox(height: 10),
              _buildSecurityOption('Verify Email', Icons.email, Colors.green),
              const SizedBox(height: 10),
              _buildSecurityOption(
                'Two-Factor Auth',
                Icons.shield,
                Colors.orange,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSecurityOption(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[500]),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Terms of Service'),
          content: const Text(
            'By using FireFit, you agree to our terms & conditions. '
            'We collect your fitness data to improve your experience. '
            'You can delete your data anytime in your account settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Agree'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Contact Us'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildContactOption(
                'Email Support',
                'support@firefit.com',
                Icons.email,
              ),
              const SizedBox(height: 10),
              _buildContactOption(
                'Help Center',
                'Visit our help center',
                Icons.help,
              ),
              const SizedBox(height: 10),
              _buildContactOption(
                'Feedback',
                'Send us feedback',
                Icons.feedback,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactOption(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Export Your Data'),
          content: const Text(
            'You can export your workout history as a CSV file. '
            'This includes all your runs, distances, times, and calories burned.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Export Now'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later'),
            ),
          ],
        );
      },
    );
  }
}
