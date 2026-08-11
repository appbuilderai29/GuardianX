// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CitizenDashboard extends StatefulWidget {
  const CitizenDashboard({super.key});

  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends State<CitizenDashboard> {
  bool isLoading = true;

  String fullName = '';
  String email = '';
  String phone = '';
  String address = '';
  String bloodGroup = '';
  String emergencyContact1 = '';
  String emergencyContact2 = '';

  @override
  void initState() {
    super.initState();
    loadCitizenData();
  }

  // ============================================================
  // LOAD CITIZEN DATA FROM FIRESTORE
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

      // Get the user's document using Firebase Authentication UID
      final DocumentSnapshot<Map<String, dynamic>> document =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!document.exists) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        return;
      }

      final data = document.data();

      if (!mounted) return;

      setState(() {
        fullName = data?['fullName'] ?? user.displayName ?? 'Citizen';
        email = data?['email'] ?? user.email ?? '';
        phone = data?['phone'] ?? '';
        address = data?['address'] ?? '';
        bloodGroup = data?['bloodGroup'] ?? '';
        emergencyContact1 = data?['emergencyContact1'] ?? '';
        emergencyContact2 = data?['emergencyContact2'] ?? '';

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load your information: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget informationCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      color: const Color(0xFF1E1E1E),
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value.isEmpty ? 'Not provided' : value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMERGENCY CONTACT CARD
  // ============================================================

  Widget emergencyCard({
    required String title,
    required String number,
    required IconData icon,
  }) {
    return Card(
      color: const Color(0xFF2A1515),
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(
          color: Colors.red,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading: const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(
            Icons.emergency,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            number.isEmpty ? 'Not provided' : number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.phone,
            color: Colors.green,
          ),
          onPressed: number.isEmpty
              ? null
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling $number'),
                    ),
                  );
                },
        ),
      ),
    );
  }

  // ============================================================
  // BUILD DASHBOARD
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
        title: const Text(
          'Citizen Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadCitizenData,
          ),
        ],
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
          // DASHBOARD CONTENT
          // ====================================================

          : RefreshIndicator(
              color: Colors.red,
              onRefresh: loadCitizenData,

              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ==================================================
                    // WELCOME SECTION
                    // ==================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.red,
                            Color(0xFF7A0000),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Row(
                        children: [

                          const CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white,

                            child: Icon(
                              Icons.person,
                              color: Colors.red,
                              size: 38,
                            ),
                          ),

                          const SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                const Text(
                                  'Welcome back,',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  fullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                const Text(
                                  'GuardianX Citizen',
                                  style: TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // EMERGENCY BUTTON
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 85,

                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Emergency feature activated!',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),

                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: const [
                            Icon(
                              Icons.warning_rounded,
                              size: 35,
                            ),

                            SizedBox(width: 15),

                            Text(
                              'EMERGENCY SOS',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // PERSONAL INFORMATION
                    // ==================================================

                    const Text(
                      'My Information',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    informationCard(
                      icon: Icons.person,
                      title: 'Full Name',
                      value: fullName,
                    ),

                    informationCard(
                      icon: Icons.email,
                      title: 'Email',
                      value: email,
                    ),

                    informationCard(
                      icon: Icons.phone,
                      title: 'Phone Number',
                      value: phone,
                    ),

                    informationCard(
                      icon: Icons.location_on,
                      title: 'Address',
                      value: address,
                    ),

                    informationCard(
                      icon: Icons.bloodtype,
                      title: 'Blood Group',
                      value: bloodGroup,
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // EMERGENCY CONTACTS
                    // ==================================================

                    const Text(
                      'Emergency Contacts',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    emergencyCard(
                      title: 'Emergency Contact 1',
                      number: emergencyContact1,
                      icon: Icons.contact_phone,
                    ),

                    emergencyCard(
                      title: 'Emergency Contact 2',
                      number: emergencyContact2,
                      icon: Icons.contact_phone,
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // DATA SOURCE
                    // ==================================================

                    Center(
                      child: Text(
                        'Your information is securely stored in GuardianX',
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}