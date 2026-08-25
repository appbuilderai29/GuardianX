// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'role_selection_screen.dart';

import 'citizen/citizen_dashboard.dart';
import 'hospital/hospital_dashboard.dart';
import 'police/police_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    checkUser();
  }

  // ============================================================
  // CHECK USER
  // ============================================================

  Future<void> checkUser() async {
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    final User? user =
        FirebaseAuth.instance.currentUser;

    // ==========================================================
    // USER NOT LOGGED IN
    // ==========================================================

    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const LoginScreen(),
        ),
      );

      return;
    }

    // ==========================================================
    // USER IS LOGGED IN
    // ==========================================================

    try {
      debugPrint(
        '======================================',
      );

      debugPrint('LOGGED-IN USER');
      debugPrint('UID: ${user.uid}');
      debugPrint('EMAIL: ${user.email}');

      debugPrint(
        '======================================',
      );

      // ========================================================
      // GET USER DOCUMENT
      // ========================================================

      final DocumentSnapshot<
          Map<String, dynamic>> document =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!mounted) return;

      debugPrint(
        'FIRESTORE DOCUMENT EXISTS: '
        '${document.exists}',
      );

      debugPrint(
        'FIRESTORE DATA: '
        '${document.data()}',
      );

      // ========================================================
      // NO DOCUMENT
      // ========================================================

      if (!document.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const RoleSelectionScreen(),
          ),
        );

        return;
      }

      final Map<String, dynamic>? data =
          document.data();

      final String role =
          data?['role']?.toString() ?? '';

      // ========================================================
      // CITIZEN
      // ========================================================

      if (role == 'citizen' &&
          data?['citizenRegistered'] == true) {

        debugPrint(
          'Citizen registered.',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const CitizenDashboard(),
          ),
        );

        return;
      }

      // ========================================================
      // HOSPITAL
      // ========================================================

      if (role == 'hospital' &&
          data?['hospitalRegistered'] == true) {

        debugPrint(
          'Hospital registered.',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const HospitalDashboard(),
          ),
        );

        return;
      }

      // ========================================================
      // POLICE
      // ========================================================

      if (role == 'police' &&
          data?['policeRegistered'] == true) {

        debugPrint(
          'Police registered.',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const PoliceDashboard(),
          ),
        );

        return;
      }

      // ========================================================
      // AMBULANCE
      // ========================================================
      //
      // If your ambulance registration already uses
      // ambulanceRegistered == true, you can add its dashboard
      // here later.
      //
      // ========================================================

      // ========================================================
      // ROLE EXISTS BUT REGISTRATION NOT COMPLETE
      // ========================================================

      if (role.isNotEmpty) {
        debugPrint(
          'Role found but registration incomplete: $role',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const RoleSelectionScreen(),
          ),
        );

        return;
      }

      // ========================================================
      // NO ROLE
      // ========================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const RoleSelectionScreen(),
        ),
      );
    } catch (e) {
      debugPrint(
        '======================================',
      );

      debugPrint('FIRESTORE ERROR');
      debugPrint(e.toString());

      debugPrint(
        '======================================',
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const LoginScreen(),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.security,
              size: 120,
              color: Colors.red,
            ),

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
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 40),

            const CircularProgressIndicator(
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}