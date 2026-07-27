import 'dart:async';
import 'package:flutter/material.dart';
import './login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    debugPrint("Splash Screen Loaded");

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 180, color: Colors.red),
            const SizedBox(height: 20),

            const Text(
              "GuardianX",
              style: TextStyle(
                color: Color.fromARGB(255, 201, 14, 14),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Every Second Matters",
              style: TextStyle(
                color: Color.fromARGB(179, 211, 25, 25),
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 40),

            const CircularProgressIndicator(
              color: Color.fromARGB(255, 211, 16, 16),
            ),
          ],
        ),
      ),
    );
  }
}
