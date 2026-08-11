// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'citizen_dashboard.dart';

class CitizenRegisterScreen extends StatefulWidget {
  const CitizenRegisterScreen({super.key});

  @override
  State<CitizenRegisterScreen> createState() =>
      _CitizenRegisterScreenState();
}

class _CitizenRegisterScreenState extends State<CitizenRegisterScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController bloodController = TextEditingController();
  final TextEditingController emergency1Controller =
      TextEditingController();
  final TextEditingController emergency2Controller =
      TextEditingController();

  bool isLoading = true;
  bool isSaving = false;
  bool hidePassword = true;

  bool alreadyRegistered = false;

  @override
  void initState() {
    super.initState();

    loadCitizenData();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    addressController.dispose();
    bloodController.dispose();
    emergency1Controller.dispose();
    emergency2Controller.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD EXISTING CITIZEN DATA
  // ============================================================

  Future<void> loadCitizenData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        return;
      }

      // ----------------------------------------------------------
      // GET USER DOCUMENT USING AUTH UID
      // ----------------------------------------------------------

      final DocumentSnapshot<Map<String, dynamic>> document =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      // ----------------------------------------------------------
      // NO DOCUMENT
      // ----------------------------------------------------------

      if (!document.exists) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        return;
      }

      final data = document.data();

      if (data == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        return;
      }

      // ----------------------------------------------------------
      // CHECK CITIZEN REGISTRATION
      // ----------------------------------------------------------

      final String role = data['role']?.toString() ?? '';

      final bool citizenRegistered =
          data['citizenRegistered'] == true;

      // ----------------------------------------------------------
      // IF ALREADY REGISTERED
      // ----------------------------------------------------------

      if (role == 'citizen' && citizenRegistered) {
        alreadyRegistered = true;

        // Load saved information into fields
        nameController.text =
            data['fullName']?.toString() ?? '';

        phoneController.text =
            data['phone']?.toString() ?? '';

        emailController.text =
            data['email']?.toString() ??
            user.email ??
            '';

        addressController.text =
            data['address']?.toString() ?? '';

        bloodController.text =
            data['bloodGroup']?.toString() ?? '';

        emergency1Controller.text =
            data['emergencyContact1']?.toString() ?? '';

        emergency2Controller.text =
            data['emergencyContact2']?.toString() ?? '';
      } else {
        // --------------------------------------------------------
        // NEW CITIZEN
        // --------------------------------------------------------

        emailController.text = user.email ?? '';
      }

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading citizen data: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load citizen information: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // SAVE CITIZEN INFORMATION
  // ============================================================

  Future<void> registerCitizen() async {
    final String name = nameController.text.trim();
    final String phone = phoneController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final String address = addressController.text.trim();
    final String bloodGroup = bloodController.text.trim();
    final String emergency1 =
        emergency1Controller.text.trim();
    final String emergency2 =
        emergency2Controller.text.trim();

    // ==========================================================
    // VALIDATION
    // ==========================================================

    if (name.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        address.isEmpty ||
        bloodGroup.isEmpty ||
        emergency1.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in all required fields',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // Password is only required for a NEW registration.
    if (!alreadyRegistered && password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a password'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    if (!alreadyRegistered && password.length < 6) {
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

    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid phone number',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // ========================================================
      // GET CURRENT AUTH USER
      // ========================================================

      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception(
          'No logged-in Firebase user found.',
        );
      }

      // ========================================================
      // SAVE TO FIRESTORE
      // ========================================================

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'uid': user.uid,

          'role': 'citizen',

          'fullName': name,
          'phone': phone,
          'email': email,

          'address': address,
          'bloodGroup': bloodGroup,

          'emergencyContact1': emergency1,
          'emergencyContact2': emergency2,

          'citizenRegistered': true,

          'citizenRegisteredAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // ========================================================
      // UPDATE AUTH DISPLAY NAME
      // ========================================================

      await user.updateDisplayName(name);

      if (!mounted) return;

      setState(() {
        isSaving = false;
        alreadyRegistered = true;
      });

      // ========================================================
      // SUCCESS
      // ========================================================

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Citizen information saved successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // ========================================================
      // GO TO DASHBOARD
      // ========================================================

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const CitizenDashboard(),
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
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
        isSaving = false;
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
    String label, {
    IconData icon = Icons.edit,
    TextInputType keyboardType =
        TextInputType.text,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,

        style: const TextStyle(
          color: Colors.white,
        ),

        decoration: InputDecoration(
          labelText: label,

          labelStyle: const TextStyle(
            color: Colors.white70,
          ),

          filled: true,

          fillColor: Colors.grey.shade900,

          prefixIcon: Icon(
            icon,
            color: Colors.red,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),

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

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: Text(
          alreadyRegistered
              ? 'Citizen Profile'
              : 'Citizen Registration',
        ),

        centerTitle: true,

        backgroundColor: Colors.red,

        foregroundColor: Colors.white,
      ),

      // ========================================================
      // LOADING
      // ========================================================

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            )

          // ====================================================
          // FORM
          // ====================================================

          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [

                  const SizedBox(height: 10),

                  // ==================================================
                  // ICON
                  // ==================================================

                  const Icon(
                    Icons.person,
                    size: 90,
                    color: Colors.red,
                  ),

                  const SizedBox(height: 15),

                  // ==================================================
                  // TITLE
                  // ==================================================

                  Text(
                    alreadyRegistered
                        ? 'Your Citizen Profile'
                        : 'Citizen Registration',

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    alreadyRegistered
                        ? 'Your saved information'
                        : 'Enter your emergency information',

                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // PERSONAL INFORMATION
                  // ==================================================

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Personal Information',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  buildField(
                    nameController,
                    'Full Name',
                    icon: Icons.person,
                  ),

                  buildField(
                    phoneController,
                    'Phone Number',
                    icon: Icons.phone,
                    keyboardType:
                        TextInputType.phone,
                  ),

                  buildField(
                    emailController,
                    'Email',
                    icon: Icons.email,
                    keyboardType:
                        TextInputType.emailAddress,
                    readOnly: true,
                  ),

                  // ==================================================
                  // PASSWORD
                  // ==================================================

                  // Only show password for NEW registration.
                  if (!alreadyRegistered)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: 15),

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

                          filled: true,

                          fillColor:
                              Colors.grey.shade900,

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

                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              15,
                            ),
                          ),

                          enabledBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              15,
                            ),
                            borderSide:
                                const BorderSide(
                              color: Colors.white24,
                            ),
                          ),

                          focusedBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              15,
                            ),
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
                  // ADDRESS
                  // ==================================================

                  buildField(
                    addressController,
                    'Address',
                    icon: Icons.location_on,
                  ),

                  const SizedBox(height: 10),

                  // ==================================================
                  // EMERGENCY INFORMATION
                  // ==================================================

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Emergency Information',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  buildField(
                    bloodController,
                    'Blood Group',
                    icon: Icons.bloodtype,
                  ),

                  buildField(
                    emergency1Controller,
                    'Emergency Contact 1',
                    icon: Icons.contact_phone,
                    keyboardType:
                        TextInputType.phone,
                  ),

                  buildField(
                    emergency2Controller,
                    'Emergency Contact 2',
                    icon: Icons.contact_phone,
                    keyboardType:
                        TextInputType.phone,
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // REGISTER / UPDATE BUTTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      onPressed:
                          isSaving
                              ? null
                              : registerCitizen,

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
                            15,
                          ),
                        ),
                      ),

                      child: isSaving
                          ? const SizedBox(
                              width: 25,
                              height: 25,
                              child:
                                  CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              alreadyRegistered
                                  ? 'UPDATE INFORMATION'
                                  : 'REGISTER CITIZEN',

                              style:
                                  const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ==================================================
                  // DASHBOARD BUTTON FOR ALREADY REGISTERED USER
                  // ==================================================

                  if (alreadyRegistered)
                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CitizenDashboard(),
                            ),
                          );
                        },

                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor:
                              Colors.red,

                          side:
                              const BorderSide(
                            color: Colors.red,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              15,
                            ),
                          ),
                        ),

                        child: const Text(
                          'GO TO DASHBOARD',
                          style: TextStyle(
                            fontSize: 16,
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