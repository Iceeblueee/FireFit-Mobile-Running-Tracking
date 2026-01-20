import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!isEmailVerified) {
      // Hanya kirim jika tidak sedang terkena blokir (opsional: bisa dipanggil manual saja)
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    try {
      await FirebaseAuth.instance.currentUser?.reload();

      if (mounted) {
        setState(() {
          isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
        });
      }

      if (isEmailVerified) {
        timer?.cancel();
      }
    } catch (e) {
      debugPrint("Error checking status: $e");
    }
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      if (mounted) {
        setState(() => canResendEmail = false);
      }

      // Cooldown diperpanjang menjadi 30 detik untuk keamanan ekstra
      await Future.delayed(const Duration(seconds: 30));

      if (mounted) {
        setState(() => canResendEmail = true);
      }
    } on FirebaseAuthException catch (e) {
      // PENANGANAN ERROR SPESIFIK FIREBASE
      String errorMessage = "An error occurred. Please try again.";

      if (e.code == 'too-many-requests') {
        errorMessage =
            "Aktivitas terlalu sering. Harap tunggu beberapa menit sebelum mencoba lagi.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      // Jika error too-many-requests, paksa tombol resend mati lebih lama
      await Future.delayed(const Duration(minutes: 2));
      if (mounted) setState(() => canResendEmail = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEmailVerified) {
      return _buildSuccessUI();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Verify Your Email"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mark_email_read_outlined,
              size: 100,
              color: Colors.orange,
            ),
            const SizedBox(height: 30),
            const Text(
              'Verification link has been sent.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 15),
            const Text(
              'If the email doesn\'t appear, please wait a moment or check your spam folder.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canResendEmail ? sendVerificationEmail : null,
                icon: const Icon(Icons.email),
                label: Text(canResendEmail ? "Resend Email" : "Please wait..."),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),
            TextButton(
              onPressed: () => FirebaseAuth.instance.signOut().then(
                (_) => Navigator.pop(context),
              ),
              child: const Text(
                "Cancel & Sign Out",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessUI() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green,
                child: Icon(Icons.check, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 30),
              const Text(
                'Success!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your email has been successfully verified.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Back to Settings",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
