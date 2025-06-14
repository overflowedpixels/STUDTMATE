import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool isSending = false;

  void showSnackbar(String message, [Color? color]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color ?? Colors.red),
    );
  }

  Future<void> sendResetEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showSnackbar("Please enter your email");
      return;
    }

    setState(() => isSending = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showSnackbar("Reset link sent to $email", Colors.green);
    } on FirebaseAuthException catch (e) {
      showSnackbar(e.message ?? "Error sending reset email");
    } catch (e) {
      showSnackbar("Unexpected error: $e");
    }

    if (mounted) setState(() => isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_reset, size: 100, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              "Enter your email to receive a password reset link.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSending ? null : sendResetEmail,
              child: Text(isSending ? "Sending..." : "Send Reset Email"),
            ),
          ],
        ),
      ),
    );
  }
}
