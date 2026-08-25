// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:guardianx/screens/citizen/citizen_register.dart';
import 'package:guardianx/screens/ambulance/ambulance_register.dart';
import 'package:guardianx/screens/hospital/hospital_register.dart';
import 'package:guardianx/screens/hospital/hospital_dashboard.dart';
import 'package:guardianx/screens/police/police_register.dart';
import 'package:guardianx/screens/police/police_dashboard.dart';
import 'package:guardianx/screens/citizen/citizen_dashboard.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool isSaving = false;

  // ============================================================
  // SELECT ROLE
  // ============================================================

  Future<void> selectRole({required String role, required Widget page}) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final DocumentSnapshot<Map<String, dynamic>> document =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      final data = document.data();

      // ========================================================
      // HOSPITAL ALREADY REGISTERED
      // ========================================================

      if (role == 'hospital' &&
          data != null &&
          data['hospitalRegistered'] == true) {
        if (!mounted) return;

        setState(() {
          isSaving = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HospitalDashboard()),
        );

        return;
      }

      // ========================================================
      // CITIZEN ALREADY REGISTERED
      // ========================================================

      if (role == 'citizen' &&
          data != null &&
          data['citizenRegistered'] == true) {
        if (!mounted) return;

        setState(() {
          isSaving = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CitizenDashboard()),
        );

        return;
      }

      // ========================================================
      // POLICE ALREADY REGISTERED
      // ========================================================

      if (role == 'police' &&
          data != null &&
          data['policeRegistered'] == true) {
        if (!mounted) return;

        setState(() {
          isSaving = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PoliceDashboard()),
        );

        return;
      }

      // ========================================================
      // SAVE SELECTED ROLE
      // ========================================================

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'role': role,
        'roleSelectedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      // ========================================================
      // OPEN REGISTRATION PAGE
      // ========================================================

      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firebase error: ${e.message ?? e.code}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // ROLE CARD
  // ============================================================

  Widget roleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String role,
    required Widget page,
  }) {
    return Card(
      color: const Color(0xFF1E1E1E),
      elevation: 8,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: ListTile(
        contentPadding: const EdgeInsets.all(18),

        leading: CircleAvatar(
          radius: 28,
          backgroundColor: color,

          child: Icon(icon, color: Colors.white, size: 30),
        ),

        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),

        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),

        onTap: isSaving
            ? null
            : () {
                selectRole(role: role, page: page);
              },
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text(
          'Select Your Role',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),

            child: ListView(
              children: [
                const SizedBox(height: 20),

                const Icon(Icons.security, size: 90, color: Colors.red),

                const SizedBox(height: 15),

                const Center(
                  child: Text(
                    'GuardianX',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Center(
                  child: Text(
                    'Choose your role to continue',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 35),

                // ==================================================
                // CITIZEN
                // ==================================================
                roleCard(
                  icon: Icons.person,
                  title: 'Citizen',
                  subtitle: 'Get emergency assistance',
                  color: Colors.blue,
                  role: 'citizen',
                  page: const CitizenRegisterScreen(),
                ),

                const SizedBox(height: 15),

                // ==================================================
                // AMBULANCE
                // ==================================================
                roleCard(
                  icon: Icons.local_shipping,
                  title: 'Ambulance Driver',
                  subtitle: 'Respond to emergency calls',
                  color: Colors.red,
                  role: 'ambulance',
                  page: const AmbulanceRegisterScreen(),
                ),

                const SizedBox(height: 15),

                // ==================================================
                // HOSPITAL
                // ==================================================
                roleCard(
                  icon: Icons.local_hospital,
                  title: 'Hospital',
                  subtitle: 'Manage emergency patients',
                  color: Colors.green,
                  role: 'hospital',
                  page: const HospitalRegisterScreen(),
                ),

                const SizedBox(height: 15),

                // ==================================================
                // POLICE
                // ==================================================
                roleCard(
                  icon: Icons.local_police,
                  title: 'Police',
                  subtitle: 'Respond to public threats',
                  color: Colors.orange,
                  role: 'police',
                  page: const PoliceRegisterScreen(),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),

          // ======================================================
          // LOADING
          // ======================================================
          if (isSaving)
            Container(
              color: Colors.black54,

              child: const Center(
                child: CircularProgressIndicator(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
