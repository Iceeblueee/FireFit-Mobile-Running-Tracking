import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  bool _is2FAEnabled = false;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _load2FAStatus();
  }

  void _load2FAStatus() async {
    var doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      _is2FAEnabled = doc.data()?['twoFactorEnabled'] ?? false;
    });
  }

  void _toggle2FA(bool value) async {
    setState(() => _is2FAEnabled = value);
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'twoFactorEnabled': value,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Two-Factor Auth"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: ListTile(
        title: const Text("Enable 2FA"),
        subtitle: const Text("Keep your account extra secure"),
        trailing: Switch(value: _is2FAEnabled, onChanged: _toggle2FA),
      ),
    );
  }
}