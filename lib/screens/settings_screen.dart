// screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart'; // Tetap fungsional
import 'export_data_screen.dart'; // Tetap fungsional untuk PDF Export

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
              child: const Icon(Icons.settings, color: Colors.blue, size: 70),
            ),
            const SizedBox(height: 10),
            const Text(
              'Settings',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // === Account ===
            _buildListTile(
              context,
              icon: Icons.person,
              color: Colors.blue,
              title: 'Account',
              subtitle: 'Manage your profile',
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

            // === Security (Hanya menyisakan Verify Email) ===
            _buildListTile(
              context,
              icon: Icons.security,
              color: Colors.purple,
              title: 'Security',
              subtitle: 'Verify your email address',
              onTap: () {
                _showSecurityDialog(context);
              },
            ),
            const Divider(),

            // === Terms of Service ===
            _buildListTile(
              context,
              icon: Icons.description,
              color: Colors.teal,
              title: 'Terms of Service',
              subtitle: 'Read our terms & conditions',
              onTap: () => _showTermsDialog(context),
            ),
            const Divider(),

            // === Contact Us ===
            _buildListTile(
              context,
              icon: Icons.email,
              color: Colors.indigo,
              title: 'Contact Us',
              subtitle: 'Reach out for support',
              onTap: () => _showContactDialog(context),
            ),
            const Divider(),

            // === Export Data (Menuju Layar PDF Export) ===
            _buildListTile(
              context,
              icon: Icons.download,
              color: Colors.blue,
              title: 'Export Data',
              subtitle: 'Download your workout history (PDF)',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExportDataScreen(),
                  ),
                );
              },
            ),
            const Divider(),

            // === Logout ===
            _buildListTile(
              context,
              icon: Icons.exit_to_app,
              color: Colors.red,
              title: 'Logout',
              titleColor: Colors.red,
              subtitle: 'Sign out from your account',
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget Utama untuk konsistensi UI
  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor ?? Colors.black,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  // Dialog Security yang kini hanya berisi Verify Email
  void _showSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Security Options'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSecurityOption(
                context,
                title: 'Verify Email',
                icon: Icons.email,
                color: Colors.green,
                screen: const VerifyEmailScreen(),
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

  // Helper navigasi dialog
  Widget _buildSecurityOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Tutup dialog
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const Text(
          'By using FireFit, you agree to our terms & conditions. We collect your fitness data to improve your experience.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Us'),
        content: const Text(
          'Email: support@firefit.com\nWebsite: www.firefit.com',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
