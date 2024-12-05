import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Tambahkan import ini
import 'package:flutterfptekber/screens/login_screen.dart'; // Pastikan path ini benar

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Pastikan Flutter sudah siap untuk menjalankan aplikasi
  await Firebase
      .initializeApp(); // Inisialisasi Firebase sebelum aplikasi dimulai
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Tracker',
      theme: ThemeData(
        primaryColor: const Color(0xFF6b5b95),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginScreen(), // Mulai dari LoginScreen
    );
  }
}
