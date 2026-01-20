// screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'export_data_screen.dart'; // Import Baru

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
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
            ),
            const Divider(),
            // === Security ===
            _buildListTile(
              context,
              icon: Icons.security,
              color: Colors.purple,
              title: 'Security',
              subtitle: 'Change password & verify email',
              onTap: () => _showSecurityDialog(context),
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
            // === Export Data === (DIPERBARUI)
            _buildListTile(
              context,
              icon: Icons.download,
              color: Colors.blue,
              title: 'Export Data',
              subtitle: 'Download your workout history',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExportDataScreen()),
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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk merapikan kode
  Widget _buildListTile(BuildContext context,
      {required IconData icon,
      required Color color,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
      Color? titleColor}) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: TextStyle(color: titleColor)),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  // Dialog-dialog pendukung (tetap sama seperti sebelumnya)
  void _showSecurityDialog(BuildContext context) { /* ... isi sama ... */ }
  void _showTermsDialog(BuildContext context) { /* ... isi sama ... */ }
  void _showContactDialog(BuildContext context) { /* ... isi sama ... */ }
}