// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HospitalDashboard extends StatefulWidget {
  const HospitalDashboard({super.key});

  @override
  State<HospitalDashboard> createState() =>
      _HospitalDashboardState();
}

class _HospitalDashboardState
    extends State<HospitalDashboard> {
  bool isLoading = true;

  String hospitalName = 'Hospital';
  String hospitalId = '-';
  String hospitalType = '-';
  String phone = '-';
  String email = '-';
  String address = '-';

  int availableBeds = 0;
  int icuBeds = 0;
  int ambulanceCount = 0;

  String hospitalStatus = 'active';

  // ============================================================
  // LOAD HOSPITAL DATA
  // ============================================================

  Future<void> loadHospitalData() async {
    try {
      final User? user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        return;
      }

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

      if (data == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        return;
      }

      if (!mounted) return;

      setState(() {
        hospitalName =
            data['hospitalName']?.toString() ?? 'Hospital';

        hospitalId =
            data['hospitalId']?.toString() ?? '-';

        hospitalType =
            data['hospitalType']?.toString() ?? '-';

        phone =
            data['phone']?.toString() ?? '-';

        email =
            data['email']?.toString() ?? '-';

        address =
            data['address']?.toString() ?? '-';

        availableBeds =
            data['availableBeds'] ?? 0;

        icuBeds =
            data['icuBeds'] ?? 0;

        ambulanceCount =
            data['ambulanceCount'] ?? 0;

        hospitalStatus =
            data['hospitalStatus']?.toString() ?? 'active';

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load hospital data: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    loadHospitalData();
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color getStatusColor() {
    if (hospitalStatus.toLowerCase() == 'active') {
      return Colors.green;
    }

    if (hospitalStatus.toLowerCase() == 'busy') {
      return Colors.orange;
    }

    return Colors.red;
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget infoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white12,
        ),
      ),

      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,

            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CAPACITY CARD
  // ============================================================

  Widget capacityCard({
    required IconData icon,
    required String title,
    required int value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 10,
        ),

        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white12,
          ),
        ),

        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 35,
            ),

            const SizedBox(height: 10),

            Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
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

        title: const Text(
          'Hospital Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
            ),

            onPressed: () {
              setState(() {
                isLoading = true;
              });

              loadHospitalData();
            },
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            )

          : RefreshIndicator(
              color: Colors.red,

              onRefresh: loadHospitalData,

              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding:
                    const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // ==================================================
                    // HOSPITAL HEADER
                    // ==================================================

                    Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.all(20),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(0xFF1E1E1E),

                        borderRadius:
                            BorderRadius.circular(20),

                        border: Border.all(
                          color: Colors.red
                              .withValues(alpha: 0.4),
                        ),
                      ),

                      child: Row(
                        children: [
                          Container(
                            height: 65,
                            width: 65,

                            decoration:
                                BoxDecoration(
                              color: Colors.red
                                  .withValues(alpha: 0.15),

                              borderRadius:
                                  BorderRadius.circular(
                                      18),
                            ),

                            child: const Icon(
                              Icons.local_hospital,
                              color: Colors.red,
                              size: 38,
                            ),
                          ),

                          const SizedBox(
                            width: 15,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [
                                Text(
                                  hospitalName,
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize: 21,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 5,
                                ),

                                Text(
                                  'Hospital ID: $hospitalId',
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // STATUS
                    // ==================================================

                    Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 15,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            getStatusColor()
                                .withValues(alpha: 0.12),

                        borderRadius:
                            BorderRadius.circular(15),

                        border: Border.all(
                          color:
                              getStatusColor(),
                        ),
                      ),

                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color:
                                getStatusColor(),
                            size: 15,
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          const Text(
                            'Hospital Status',
                            style:
                                TextStyle(
                              color:
                                  Colors.white70,
                              fontSize: 14,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            hospitalStatus
                                .toUpperCase(),

                            style:
                                TextStyle(
                              color:
                                  getStatusColor(),
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // EMERGENCY CAPACITY
                    // ==================================================

                    const Text(
                      'Emergency Capacity',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 19,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        capacityCard(
                          icon: Icons.bed,
                          title:
                              'Available Beds',
                          value:
                              availableBeds,
                          color:
                              Colors.blue,
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        capacityCard(
                          icon:
                              Icons.monitor_heart,
                          title: 'ICU Beds',
                          value: icuBeds,
                          color:
                              Colors.red,
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        capacityCard(
                          icon:
                              Icons.local_shipping,
                          title:
                              'Ambulances',
                          value:
                              ambulanceCount,
                          color:
                              Colors.orange,
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // HOSPITAL INFORMATION
                    // ==================================================

                    const Text(
                      'Hospital Information',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 19,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    infoCard(
                      icon: Icons.category,
                      title: 'Hospital Type',
                      value: hospitalType,
                      color: Colors.green,
                    ),

                    const SizedBox(height: 12),

                    infoCard(
                      icon: Icons.phone,
                      title: 'Phone Number',
                      value: phone,
                      color: Colors.blue,
                    ),

                    const SizedBox(height: 12),

                    infoCard(
                      icon: Icons.email,
                      title: 'Email',
                      value: email,
                      color: Colors.orange,
                    ),

                    const SizedBox(height: 12),

                    infoCard(
                      icon: Icons.location_on,
                      title: 'Address',
                      value: address,
                      color: Colors.red,
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // EMERGENCY REQUESTS
                    // ==================================================
// ==================================================
// EMERGENCY REQUESTS
// ==================================================

const Text(
  'Emergency Requests',
  style: TextStyle(
    color: Colors.red,
    fontSize: 19,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
  stream: FirebaseFirestore.instance
      .collection('emergencies')
      .where('type', isEqualTo: 'SOS')
      .where('status', isEqualTo: 'active')
      .orderBy('createdAt', descending: true)
      .snapshots(),

  builder: (context, snapshot) {

    // Loading
    if (snapshot.connectionState ==
        ConnectionState.waiting) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.red,
          ),
        ),
      );
    }

    // Error
    if (snapshot.hasError) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          'Unable to load emergencies:\n${snapshot.error}',
          style: const TextStyle(
            color: Colors.red,
          ),
        ),
      );
    }

    // No emergencies
    if (!snapshot.hasData ||
        snapshot.data!.docs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white12,
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.notifications_none,
              color: Colors.white38,
              size: 50,
            ),

            SizedBox(height: 10),

            Text(
              'No emergency requests',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 5),

            Text(
              'Incoming SOS requests will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white38,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    // Emergency list
    final emergencies = snapshot.data!.docs;

    return Column(
      children: emergencies.map((doc) {

        final data = doc.data();

        final String userName =
            data['userName']?.toString() ?? 'Unknown User';

        final String userId =
            data['userId']?.toString() ?? '-';

        final String status =
            data['status']?.toString() ?? 'active';

        final String type =
            data['type']?.toString() ?? 'SOS';

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(
            bottom: 15,
          ),
          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.red,
              width: 1.5,
            ),
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // Header
              Row(
                children: [

                  const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(
                      Icons.warning,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'EMERGENCY SOS',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),

                    child: Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // User
              Row(
                children: [

                  const Icon(
                    Icons.person,
                    color: Colors.white70,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'User: $userName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // User ID
              Row(
                children: [

                  const Icon(
                    Icons.fingerprint,
                    color: Colors.white70,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'User ID: $userId',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Type
              Row(
                children: [

                  const Icon(
                    Icons.emergency,
                    color: Colors.orange,
                  ),

                  const SizedBox(width: 10),

                  Text(
                    'Type: $type',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Buttons
              Row(
                children: [

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Emergency from $userName',
                            ),
                          ),
                        );
                      },

                      icon: const Icon(
                        Icons.visibility,
                      ),

                      label: const Text(
                        'VIEW',
                      ),

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blue,
                        foregroundColor:
                            Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {

                        await FirebaseFirestore
                            .instance
                            .collection(
                              'emergencies',
                            )
                            .doc(doc.id)
                            .update({
                          'status': 'handled',
                        });
                      },

                      icon: const Icon(
                        Icons.check,
                      ),

                      label: const Text(
                        'HANDLE',
                      ),

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green,
                        foregroundColor:
                            Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      }).toList(),
    );
  },
),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}