import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_page.dart';
import 'calendar_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false; // Untuk menampilkan indikator loading

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      setState(() {
        _isLoading = true; // Set loading state
      });

      try {
        // Login dengan Firebase Authentication
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Navigate to the main page after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CalendarScreen(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = '';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found with that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password.';
        } else {
          errorMessage = e.message ?? 'An error occurred. Please try again.';
        }
        _showErrorDialog(errorMessage);
      } finally {
        setState(() {
          _isLoading = false; // Reset loading state
        });
      }
    } else {
      _showErrorDialog("Please fill in all fields.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Moodly",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6b5b95),
              ),
              textAlign: TextAlign.center,
            ),
            const Text(
              "Track and understand your moods effortlessly.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed:
                  _isLoading ? null : login, // Disable button during loading
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size.fromHeight(50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.black,
                    )
                  : const Text(
                      "Login",
                      style: TextStyle(color: Colors.black),
                    ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
              },
              child: const Text(
                "Don't have an account? Register here",
                style: TextStyle(color: Color(0xFFFFD700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
