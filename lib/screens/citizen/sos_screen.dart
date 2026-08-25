// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:guardianx/services/location_service.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  bool isSending = false;

  Future<void> sendSOS() async {
    if (isSending) return;

    setState(() {
      isSending = true;
    });

    try {
      // =========================================================
      // GET LOGGED-IN USER
      // =========================================================

      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Please login first.');
      }

      // =========================================================
      // GET CITIZEN DATA FROM FIRESTORE
      // =========================================================

      final DocumentSnapshot<Map<String, dynamic>> userDocument =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      final Map<String, dynamic>? userData =
          userDocument.data();

      final String userName =
          userData?['fullName']?.toString() ??
          userData?['name']?.toString() ??
          user.displayName ??
          user.email ??
          'Unknown User';

      final String phone =
          userData?['phone']?.toString() ?? '';

      final String email =
          userData?['email']?.toString() ??
          user.email ??
          '';

      final String address =
          userData?['address']?.toString() ?? '';

      // =========================================================
      // GET CURRENT GPS LOCATION
      // =========================================================

      final position =
          await LocationService.getCurrentLocation();

      // =========================================================
      // CREATE NEW EMERGENCY DOCUMENT
      // =========================================================

      final DocumentReference emergencyRef =
          await FirebaseFirestore.instance
              .collection('emergencies')
              .add({
        // User information
        'userId': user.uid,
        'userName': userName,
        'phone': phone,
        'email': email,
        'address': address,

        // Emergency information
        'type': 'SOS',
        'status': 'active',

        // GPS information
        'latitude': position.latitude,
        'longitude': position.longitude,

        // Time
        'createdAt': FieldValue.serverTimestamp(),

        // Additional timestamp
        'createdAtMillis':
            DateTime.now().millisecondsSinceEpoch,
      });

      debugPrint(
        'SOS created: ${emergencyRef.id}',
      );

      if (!mounted) return;

      setState(() {
        isSending = false;
      });

      // =========================================================
      // SUCCESS MESSAGE
      // =========================================================

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
          content: Text(
            'SOS SENT SUCCESSFULLY!\n'
            'Location: ${position.latitude}, '
            '${position.longitude}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Unable to send SOS:\n$e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text(
          'Emergency SOS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              const Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 90,
              ),

              const SizedBox(height: 25),

              const Text(
                'EMERGENCY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Press the button below to send an emergency alert.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 45),

              // =================================================
              // SOS BUTTON
              // =================================================

              GestureDetector(
                onTap: isSending ? null : sendSOS,

                child: Container(
                  height: 180,
                  width: 180,

                  decoration: BoxDecoration(
                    color: isSending
                        ? Colors.red.shade900
                        : Colors.red,

                    shape: BoxShape.circle,

                    boxShadow: [
                      BoxShadow(
                        color: Colors.red
                            .withValues(alpha: 0.35),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),

                  child: Center(
                    child: isSending
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 5,
                          )
                        : const Text(
                            'SOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              if (isSending)
                const Text(
                  'Getting your location...\nSending emergency alert...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                )
              else
                const Text(
                  'Tap the SOS button in an emergency',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}