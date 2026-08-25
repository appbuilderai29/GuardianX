// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'hospital_dashboard.dart';

class HospitalRegisterScreen extends StatefulWidget {
  const HospitalRegisterScreen({super.key});

  @override
  State<HospitalRegisterScreen> createState() =>
      _HospitalRegisterScreenState();
}

class _HospitalRegisterScreenState
    extends State<HospitalRegisterScreen> {
  final hospitalNameController = TextEditingController();
  final hospitalIdController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final addressController = TextEditingController();
  final bedsController = TextEditingController();
  final icuController = TextEditingController();
  final ambulanceController = TextEditingController();

  bool isLoading = false;
  bool hidePassword = true;

  String hospitalType = 'Government';

  @override
  void dispose() {
    hospitalNameController.dispose();
    hospitalIdController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    addressController.dispose();
    bedsController.dispose();
    icuController.dispose();
    ambulanceController.dispose();

    super.dispose();
  }

  // ============================================================
  // REGISTER HOSPITAL
  // ============================================================

  Future<void> registerHospital() async {
    final hospitalName =
        hospitalNameController.text.trim();

    final hospitalId =
        hospitalIdController.text.trim();

    final phone =
        phoneController.text.trim();

    final email =
        emailController.text.trim();

    final password =
        passwordController.text.trim();

    final address =
        addressController.text.trim();

    final beds =
        bedsController.text.trim();

    final icu =
        icuController.text.trim();

    final ambulance =
        ambulanceController.text.trim();

    // ----------------------------------------------------------
    // VALIDATION
    // ----------------------------------------------------------

    if (hospitalName.isEmpty ||
        hospitalId.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        address.isEmpty ||
        beds.isEmpty ||
        icu.isEmpty ||
        ambulance.isEmpty) {
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
      // GET CURRENT USER
      // ========================================================

      final User? user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception(
          'No logged-in user found.',
        );
      }

      // ========================================================
      // SAVE HOSPITAL INFORMATION
      // ========================================================

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'uid': user.uid,

          'role': 'hospital',

          'hospitalRegistered': true,

          'hospitalName': hospitalName,

          'hospitalId': hospitalId,

          'phone': phone,

          'email': email,

          'hospitalType': hospitalType,

          'address': address,

          'availableBeds':
              int.tryParse(beds) ?? 0,

          'icuBeds':
              int.tryParse(icu) ?? 0,

          'ambulanceCount':
              int.tryParse(ambulance) ?? 0,

          'hospitalStatus': 'active',

          'hospitalRegisteredAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // ========================================================
      // UPDATE FIREBASE DISPLAY NAME
      // ========================================================

      await user.updateDisplayName(
        hospitalName,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Hospital registration completed successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // ========================================================
      // GO TO HOSPITAL DASHBOARD
      // ========================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const HospitalDashboard(),
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

  Widget buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
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
            borderSide:
                const BorderSide(
              color: Colors.white24,
            ),
          ),

          focusedBorder: OutlineInputBorder(
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

      appBar: AppBar(
        title: const Text(
          'Hospital Registration',
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
              Icons.local_hospital,
              size: 90,
              color: Colors.red,
            ),

            const SizedBox(height: 15),

            const Text(
              'Hospital Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Register your hospital with GuardianX',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // HOSPITAL INFORMATION
            // ==================================================

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Hospital Information',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            buildField(
              hospitalNameController,
              'Hospital Name',
              Icons.local_hospital,
            ),

            buildField(
              hospitalIdController,
              'Hospital ID',
              Icons.badge,
            ),

            buildField(
              phoneController,
              'Phone Number',
              Icons.phone,
              keyboardType:
                  TextInputType.phone,
            ),

            buildField(
              emailController,
              'Email',
              Icons.email,
              keyboardType:
                  TextInputType.emailAddress,
            ),

            // ==================================================
            // PASSWORD
            // ==================================================

            Padding(
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

                  labelStyle:
                      const TextStyle(
                    color: Colors.white70,
                  ),

                  prefixIcon:
                      const Icon(
                    Icons.lock,
                    color: Colors.red,
                  ),

                  suffixIcon:
                      IconButton(
                    icon: Icon(
                      hidePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color:
                          Colors.white70,
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
                        BorderRadius.circular(
                            15),
                    borderSide:
                        const BorderSide(
                      color:
                          Colors.white24,
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                            15),
                    borderSide:
                        const BorderSide(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            // ==================================================
            // HOSPITAL TYPE
            // ==================================================

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Hospital Type',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 15,
              ),

              decoration:
                  BoxDecoration(
                color:
                    Colors.grey.shade900,
                borderRadius:
                    BorderRadius.circular(
                        15),
                border:
                    Border.all(
                  color:
                      Colors.white24,
                ),
              ),

              child:
                  DropdownButton<String>(
                value: hospitalType,

                isExpanded: true,

                dropdownColor:
                    Colors.grey.shade900,

                underline:
                    const SizedBox(),

                style:
                    const TextStyle(
                  color: Colors.white,
                ),

                items: const [
                  DropdownMenuItem(
                    value: 'Government',
                    child:
                        Text('Government'),
                  ),
                  DropdownMenuItem(
                    value: 'Private',
                    child:
                        Text('Private'),
                  ),
                  DropdownMenuItem(
                    value: 'Trust',
                    child:
                        Text('Trust'),
                  ),
                ],

                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    hospitalType =
                        value;
                  });
                },
              ),
            ),

            const SizedBox(height: 15),

            buildField(
              addressController,
              'Hospital Address',
              Icons.location_on,
            ),

            const SizedBox(height: 10),

            // ==================================================
            // EMERGENCY CAPACITY
            // ==================================================

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Emergency Capacity',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            buildField(
              bedsController,
              'Available Beds',
              Icons.bed,
              keyboardType:
                  TextInputType.number,
            ),

            buildField(
              icuController,
              'ICU Beds',
              Icons.monitor_heart,
              keyboardType:
                  TextInputType.number,
            ),

            buildField(
              ambulanceController,
              'Available Ambulances',
              Icons.local_shipping,
              keyboardType:
                  TextInputType.number,
            ),

            const SizedBox(height: 20),

            // ==================================================
            // REGISTER BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,

              height: 55,

              child:
                  ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : registerHospital,

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
                        'REGISTER HOSPITAL',
                        style: TextStyle(
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