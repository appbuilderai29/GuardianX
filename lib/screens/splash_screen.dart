import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
// ignore: unused_import
import 'role_selection_screen.dart';
import 'citizen/citizen_dashboard.dart';
import 'hospital/hospital_dashboard.dart';
import 'police/police_dashboard.dart';

// TESTING ONLY: lets you switch dashboards on one device.
import 'ambulance/ambulance_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkUser();
  }

  
Future<void> checkUser() async {
  await Future.delayed(const Duration(seconds: 2));

  if (!mounted) return;

  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const TestRoleSelectionScreen(),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 120, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'GuardianX',
              style: TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Every Second Matters',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.red),
          ],
        ),
      ),
    );
  }
}

class TestRoleSelectionScreen extends StatelessWidget {
  const TestRoleSelectionScreen({super.key});

  void openDashboard(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roles = [
      (title: 'Citizen', icon: Icons.person, screen: const CitizenDashboard()),
      (
        title: 'Ambulance Driver',
        icon: Icons.emergency,
        screen: const AmbulanceDashboard(),
      ),
      (
        title: 'Hospital',
        icon: Icons.local_hospital,
        screen: const HospitalDashboard(),
      ),
      (
        title: 'Police',
        icon: Icons.local_police,
        screen: const PoliceDashboard(),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Choose a Test Role'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'GuardianX Testing Mode',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose which dashboard to test.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          for (final role in roles)
            Card(
              color: const Color(0xFF1B1B1B),
              child: ListTile(
                leading: Icon(role.icon, color: Colors.redAccent, size: 32),
                title: Text(
                  role.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                ),
                onTap: () => openDashboard(context, role.screen),
              ),
            ),
        ],
      ),
    );
  }
}
