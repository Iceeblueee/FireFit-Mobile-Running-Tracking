// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';

      // Ambil data dari Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _dobController.text = data['dateOfBirth'] ?? '';
        _weightController.text = data['weight']?.toString() ?? '';
        _heightController.text = data['height']?.toString() ?? '';
      }
    }
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // ✅ Update displayName di Firebase Auth
    await user.updateDisplayName(_nameController.text);

    // ✅ Simpan ke Firestore
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'fullName': _nameController.text,
      'email': _emailController.text,
      'dateOfBirth': _dobController.text,
      'weight': double.tryParse(_weightController.text) ?? 0.0,
      'height': int.tryParse(_heightController.text) ?? 0,
    }, SetOptions(merge: true));

    // ✅ Refresh UI
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated!')));

    // ✅ Tutup screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveChanges),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person, size: 50),
                    ),
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.orange,
                      child: Icon(
                        Icons.camera_alt,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text('Full Name'),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'John Doe',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Email'),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'johndoe@example.com',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Date of Birth'),
              TextField(
                controller: _dobController,
                decoration: InputDecoration(
                  hintText: '12/05/1995',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Weight (kg)'),
                        TextField(
                          controller: _weightController,
                          decoration: InputDecoration(
                            hintText: '62',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Height (cm)'),
                        TextField(
                          controller: _heightController,
                          decoration: InputDecoration(
                            hintText: '168',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
