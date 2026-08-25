import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'role_selection_screen.dart';
import 'citizen/citizen_dashboard.dart';

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
    // Show splash screen for 2 seconds.
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // ==========================================================
    // CHECK AUTHENTICATION
    // ==========================================================

    final User? user = FirebaseAuth.instance.currentUser;

    // ==========================================================
    // USER NOT LOGGED IN
    // ==========================================================

    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );

      return;
    }

    // ==========================================================
    // USER IS LOGGED IN
    // ==========================================================

    try {
      debugPrint('======================================');
      debugPrint('LOGGED-IN USER');
      debugPrint('UID: ${user.uid}');
      debugPrint('EMAIL: ${user.email}');
      debugPrint('======================================');

      // Get user's Firestore document.
      final DocumentSnapshot<Map<String, dynamic>> document =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!mounted) return;

      debugPrint('FIRESTORE DOCUMENT EXISTS: ${document.exists}');
      debugPrint('FIRESTORE DOCUMENT ID: ${document.id}');
      debugPrint('FIRESTORE DATA: ${document.data()}');

      // ========================================================
      // NO FIRESTORE DOCUMENT
      // ========================================================

      if (!document.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        );

        return;
      }

      // Get document data.
      final Map<String, dynamic>? data = document.data();

      // ========================================================
      // GET ROLE
      // ========================================================

      final String? role = data?['role'];

      // ========================================================
      // CITIZEN REGISTERED
      // ========================================================

      if (role == 'citizen' && data?['citizenRegistered'] == true) {
        debugPrint('CITIZEN REGISTERED');
        debugPrint('Opening Citizen Dashboard...');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CitizenDashboard()),
        );

        return;
      }
      
      // ========================================================
      // CITIZEN ROLE EXISTS BUT REGISTRATION NOT COMPLETE
      // ========================================================

      if (role == 'citizen') {
        debugPrint('Citizen role found but registration is incomplete.');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        );

        return;
      }

      // ========================================================
      // OTHER ROLES
      // ========================================================

      if (role != null && role.isNotEmpty) {
        debugPrint('Role found: $role');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        );

        return;
      }

      // ========================================================
      // NO ROLE
      // ========================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
      );
    } catch (e) {
      // ========================================================
      // FIRESTORE ERROR
      // ========================================================

      debugPrint('======================================');
      debugPrint('FIRESTORE ERROR');
      debugPrint(e.toString());
      debugPrint('======================================');

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
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
            // ==================================================
            // GUARDIANX ICON
            // ==================================================
            const Icon(Icons.security, size: 120, color: Colors.red),

            const SizedBox(height: 20),

            // ==================================================
            // GUARDIANX NAME
            // ==================================================
            const Text(
              'GuardianX',
              style: TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // ==================================================
            // TAGLINE
            // ==================================================
            const Text(
              'Every Second Matters',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),

            const SizedBox(height: 40),

            // ==================================================
            // LOADING
            // ==================================================
            const CircularProgressIndicator(color: Colors.red),
          ],
        ),
      ),
    );
  }
}
