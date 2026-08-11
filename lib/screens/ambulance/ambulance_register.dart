// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ambulance_dashboard.dart';

class AmbulanceRegisterScreen extends StatefulWidget {
  const AmbulanceRegisterScreen({super.key});

  @override
  State<AmbulanceRegisterScreen> createState() =>
      _AmbulanceRegisterScreenState();
}

class _AmbulanceRegisterScreenState
    extends State<AmbulanceRegisterScreen> {
  final driverNameController = TextEditingController();
  final driverIdController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ambulanceNumberController = TextEditingController();
  final licenseController = TextEditingController();
  final hospitalController = TextEditingController();
  final locationController = TextEditingController();

  String status = "Available";
  bool isLoading = false;
  bool hidePassword = true;

  @override
  void dispose() {
    driverNameController.dispose();
    driverIdController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    ambulanceNumberController.dispose();
    licenseController.dispose();
    hospitalController.dispose();
    locationController.dispose();
    super.dispose();
  }

  // ============================================================
  // REGISTER AMBULANCE
  // ============================================================

  Future<void> registerAmbulance() async {
    final driverName = driverNameController.text.trim();
    final driverId = driverIdController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final ambulanceNumber =
        ambulanceNumberController.text.trim();
    final license = licenseController.text.trim();
    final hospital = hospitalController.text.trim();
    final location = locationController.text.trim();

    // Validation
    if (driverName.isEmpty ||
        driverId.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        ambulanceNumber.isEmpty ||
        license.isEmpty ||
        hospital.isEmpty ||
        location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
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
      // GET CURRENT USER
      // ========================================================

      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception(
          'No logged-in user found. Please login first.',
        );
      }

      // ========================================================
      // SAVE AMBULANCE INFORMATION
      // ========================================================

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'uid': user.uid,
          'role': 'ambulance',

          'driverName': driverName,
          'driverId': driverId,
          'phone': phone,
          'email': email,

          'ambulanceNumber': ambulanceNumber,
          'licenseNumber': license,

          'hospitalName': hospital,
          'currentLocation': location,

          'status': status,

          'ambulanceRegistered': true,
          'ambulanceRegisteredAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // Update Firebase display name
      await user.updateDisplayName(driverName);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ambulance registration completed successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // ========================================================
      // GO TO AMBULANCE DASHBOARD
      // ========================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const AmbulanceDashboard(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Authentication error',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Firebase error: ${e.message ?? e.code}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
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
  // TEXT FIELD
  // ============================================================

  Widget buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.red,
          ),
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.white70,
          ),
          filled: true,
          fillColor: Colors.grey.shade900,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Colors.white24,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text(
          'Ambulance Registration',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 10),

            const Icon(
              Icons.local_shipping,
              color: Colors.red,
              size: 90,
            ),

            const SizedBox(height: 15),

            const Text(
              'Ambulance Driver Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Enter ambulance and driver information',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // DRIVER INFORMATION
            // ==================================================

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Driver Information',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            buildField(
              driverNameController,
              'Driver Name',
              Icons.person,
            ),

            buildField(
              driverIdController,
              'Driver ID',
              Icons.badge,
            ),

            buildField(
              phoneController,
              'Phone Number',
              Icons.phone,
              keyboardType: TextInputType.phone,
            ),

            buildField(
              emailController,
              'Email',
              Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),

            // Password
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: TextField(
                controller: passwordController,
                obscureText: hidePassword,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
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
                        hidePassword = !hidePassword;
                      });
                    },
                  ),
                  labelText: 'Password',
                  labelStyle: const TextStyle(
                    color: Colors.white70,
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
            ),

            const SizedBox(height: 5),

            // ==================================================
            // AMBULANCE INFORMATION
            // ==================================================

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ambulance Information',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            buildField(
              ambulanceNumberController,
              'Ambulance Number',
              Icons.local_shipping,
            ),

            buildField(
              licenseController,
              'Driving License Number',
              Icons.credit_card,
            ),

            buildField(
              hospitalController,
              'Hospital Name',
              Icons.local_hospital,
            ),

            buildField(
              locationController,
              'Current Location',
              Icons.location_on,
            ),

            // ==================================================
            // STATUS
            // ==================================================

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Availability Status',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius:
                    BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white24,
                ),
              ),
              child: DropdownButton<String>(
                value: status,
                dropdownColor: Colors.black,
                isExpanded: true,
                underline: const SizedBox(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Available',
                    child: Text('Available'),
                  ),
                  DropdownMenuItem(
                    value: 'Busy',
                    child: Text('Busy'),
                  ),
                ],
                onChanged: isLoading
                    ? null
                    : (value) {
                        if (value == null) return;

                        setState(() {
                          status = value;
                        });
                      },
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // REGISTER BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    isLoading ? null : registerAmbulance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      Colors.red.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 25,
                        width: 25,
                        child:
                            CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'REGISTER AMBULANCE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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