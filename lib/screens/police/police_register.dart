// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'police_dashboard.dart';

class PoliceRegisterScreen extends StatefulWidget {
  const PoliceRegisterScreen({super.key});

  @override
  State<PoliceRegisterScreen> createState() =>
      _PoliceRegisterScreenState();
}

class _PoliceRegisterScreenState extends State<PoliceRegisterScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController badgeController =
      TextEditingController();

  final TextEditingController stationController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController locationController =
      TextEditingController();

  bool isLoading = false;
  bool hidePassword = true;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    badgeController.dispose();
    stationController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    locationController.dispose();

    super.dispose();
  }

  // ============================================================
  // REGISTER POLICE OFFICER
  // ============================================================

  Future<void> registerPolice() async {
    final String name =
        nameController.text.trim();

    final String badgeNumber =
        badgeController.text.trim();

    final String station =
        stationController.text.trim();

    final String phone =
        phoneController.text.trim();

    final String email =
        emailController.text.trim();

    final String password =
        passwordController.text.trim();

    final String location =
        locationController.text.trim();

    // ==========================================================
    // VALIDATION
    // ==========================================================

    if (name.isEmpty ||
        badgeNumber.isEmpty ||
        station.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in all fields',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password must be at least 6 characters',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // ========================================================
      // CREATE FIREBASE AUTH ACCOUNT
      // ========================================================

      final UserCredential userCredential =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user =
          userCredential.user;

      if (user == null) {
        throw Exception(
          'Unable to create police account.',
        );
      }

      // ========================================================
      // UPDATE DISPLAY NAME
      // ========================================================

      await user.updateDisplayName(name);

      // ========================================================
      // SAVE POLICE INFORMATION TO FIRESTORE
      // ========================================================

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          // Firebase information
          'uid': user.uid,

          // Role information
          'role': 'police',

          'policeRegistered': true,

          // Police information
          'officerName': name,

          'badgeNumber': badgeNumber,

          'policeStation': station,

          'phone': phone,

          'email': email,

          'currentLocation': location,

          // Status
          'policeStatus': 'active',

          // Registration time
          'policeRegisteredAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      // ========================================================
      // CHECK WIDGET
      // ========================================================

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      // ========================================================
      // SUCCESS MESSAGE
      // ========================================================

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Police registration completed successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // ========================================================
      // OPEN POLICE DASHBOARD
      // ========================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const PoliceDashboard(),
        ),
      );
    }

    // ==========================================================
    // FIREBASE ERROR
    // ==========================================================

    on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      String message =
          'Registration failed';

      if (e.code == 'email-already-in-use') {
        message =
            'This email is already registered.';
      } else if (e.code == 'invalid-email') {
        message =
            'Please enter a valid email address.';
      } else if (e.code == 'weak-password') {
        message =
            'Password is too weak.';
      } else if (e.code == 'network-request-failed') {
        message =
            'Please check your internet connection.';
      } else {
        message =
            e.message ?? 'Firebase registration failed.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }

    // ==========================================================
    // FIRESTORE / OTHER ERROR
    // ==========================================================

    catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType =
        TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 15,
      ),
      child: TextField(
        controller: controller,

        keyboardType: keyboardType,

        style: const TextStyle(
          color: Colors.white,
        ),

        decoration: InputDecoration(
          labelText: label,

          labelStyle: const TextStyle(
            color: Colors.white70,
          ),

          prefixIcon: Icon(
            icon,
            color: Colors.red,
          ),

          filled: true,

          fillColor: Colors.grey.shade900,

          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(15),

            borderSide: const BorderSide(
              color: Colors.white24,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(15),

            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PASSWORD FIELD
  // ============================================================

  Widget passwordField() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 15,
      ),
      child: TextField(
        controller: passwordController,

        obscureText: hidePassword,

        style: const TextStyle(
          color: Colors.white,
        ),

        decoration: InputDecoration(
          labelText: 'Password',

          labelStyle: const TextStyle(
            color: Colors.white70,
          ),

          prefixIcon: const Icon(
            Icons.lock,
            color: Colors.red,
          ),

          suffixIcon: IconButton(
            icon: Icon(
              hidePassword
                  ? Icons.visibility
                  : Icons.visibility_off,

              color: Colors.white70,
            ),

            onPressed: () {
              setState(() {
                hidePassword =
                    !hidePassword;
              });
            },
          ),

          filled: true,

          fillColor:
              Colors.grey.shade900,

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(15),

            borderSide:
                const BorderSide(
              color: Colors.white24,
            ),
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(15),

            borderSide:
                const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
        ),
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

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.red,

        foregroundColor: Colors.white,

        centerTitle: true,

        title: const Text(
          'Police Registration',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 10),

            // ==================================================
            // POLICE ICON
            // ==================================================

            const Icon(
              Icons.local_police,
              size: 90,
              color: Colors.blue,
            ),

            const SizedBox(height: 15),

            // ==================================================
            // TITLE
            // ==================================================

            const Text(
              'Police Officer Registration',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Register your police account with GuardianX',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // POLICE INFORMATION
            // ==================================================

            const Align(
              alignment:
                  Alignment.centerLeft,

              child: Text(
                'Police Information',

                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Officer Name
            buildField(
              controller: nameController,
              label: 'Officer Name',
              icon: Icons.person,
            ),

            // Badge Number
            buildField(
              controller: badgeController,
              label: 'Badge Number',
              icon: Icons.badge,
            ),

            // Police Station
            buildField(
              controller: stationController,
              label: 'Police Station',
              icon: Icons.local_police,
            ),

            // Phone
            buildField(
              controller: phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              keyboardType:
                  TextInputType.phone,
            ),

            // Email
            buildField(
              controller: emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType:
                  TextInputType.emailAddress,
            ),

            // Password
            passwordField(),

            // Location
            buildField(
              controller:
                  locationController,
              label: 'Current Location',
              icon: Icons.location_on,
            ),

            const SizedBox(height: 15),

            // ==================================================
            // REGISTER BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : registerPolice,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red,

                  foregroundColor:
                      Colors.white,

                  disabledBackgroundColor:
                      Colors.red.shade900,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            15),
                  ),
                ),

                child: isLoading
                    ? const SizedBox(
                        height: 25,
                        width: 25,

                        child:
                            CircularProgressIndicator(
                          color:
                              Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'REGISTER POLICE',

                        style:
                            TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}