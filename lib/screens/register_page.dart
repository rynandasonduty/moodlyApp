import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      if (passwordController.text.length < 6) {
        _showErrorDialog("Password must be at least 6 characters long.");
        return;
      }

      final email = emailController.text;
      final emailRegExp = RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
      if (!emailRegExp.hasMatch(email)) {
        _showErrorDialog("Please enter a valid email address.");
        return;
      }

      try {
        // Register the user with Firebase Authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // After successful registration, save the name in Firestore
        User? user = userCredential.user;
        if (user != null) {
          // Add user's full name to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'name': nameController.text,
            'email': emailController.text,
            'createdAt':
                Timestamp.now(), // Optionally track when the user was created
          });
        }

        // Show success pop-up notification
        _showSuccessDialog();
      } on FirebaseAuthException catch (e) {
        String errorMessage = '';
        if (e.code == 'weak-password') {
          errorMessage = 'The password is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'The email is already in use.';
        } else {
          errorMessage = e.message ?? 'An error occurred. Please try again.';
        }
        _showErrorDialog(errorMessage);
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

  // Show success dialog after registration
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Registration Successful"),
        content: const Text("You have successfully registered!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the success dialog
              // Navigate to the login screen after successful registration
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
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
              "Register",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6b5b95),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Full Name",
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
              onPressed: register,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                "Register",
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              child: const Text(
                "Already have an account? Login here",
                style: TextStyle(color: Color(0xFFFFD700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
