// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Mengatur delay 3 detik sebelum pindah ke Login
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo SelaData
            Image.asset(
              'assets/images/icon_aplikasi.png', 
              height: 150,
            ),
            const SizedBox(height: 24),
            // Indikator Loading agar terlihat profesional
            const CircularProgressIndicator(
              color: Color(0xFF1E824C),
            ),
          ],
        ),
      ),
    );
  }
}