// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'sos_screen.dart';

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
  // LOAD CITIZEN DATA
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

      final document = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (!document.exists) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      final data = document.data();

      setState(() {
        fullName =
            data?['fullName']?.toString() ??
            user.displayName ??
            'Citizen';

        email =
            data?['email']?.toString() ??
            user.email ??
            '';

        phone =
            data?['phone']?.toString() ??
            '';

        address =
            data?['address']?.toString() ??
            '';

        bloodGroup =
            data?['bloodGroup']?.toString() ??
            '';

        emergencyContact1 =
            data?['emergencyContact1']?.toString() ??
            '';

        emergencyContact2 =
            data?['emergencyContact2']?.toString() ??
            '';

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
            'Unable to load your information: $e',
          ),
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
                      content: Text(
                        'Calling $number',
                      ),
                    ),
                  );
                },
        ),
      ),
    );
  }

  // ============================================================
  // HOSPITAL CARD
  // ============================================================

  Widget hospitalCard(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    final String hospitalName =
        data['hospitalName']?.toString() ??
        'Hospital';

    final String hospitalId =
        data['hospitalId']?.toString() ??
        '-';

    final String hospitalType =
        data['hospitalType']?.toString() ??
        '-';

    final String hospitalPhone =
        data['phone']?.toString() ??
        '-';

    final String hospitalEmail =
        data['email']?.toString() ??
        '-';

    final String hospitalAddress =
        data['address']?.toString() ??
        '-';

    final int availableBeds =
        _toInt(data['availableBeds']);

    final int icuBeds =
        _toInt(data['icuBeds']);

    final int ambulanceCount =
        _toInt(data['ambulanceCount']);

    final String status =
        data['hospitalStatus']?.toString() ??
        'active';

    final bool isActive =
        status.toLowerCase() == 'active';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 18,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withValues(
            alpha: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          // ==================================================
          // HOSPITAL HEADER
          // ==================================================

          Row(
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(
                    alpha: 0.15,
                  ),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: Colors.red,
                  size: 32,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospitalName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Hospital ID: $hospitalId',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green
                      : Colors.red,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  isActive
                      ? 'ACTIVE'
                      : 'INACTIVE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ==================================================
          // HOSPITAL TYPE
          // ==================================================

          hospitalDetailRow(
            Icons.category,
            'Type',
            hospitalType,
          ),

          hospitalDetailRow(
            Icons.phone,
            'Phone',
            hospitalPhone,
          ),

          hospitalDetailRow(
            Icons.email,
            'Email',
            hospitalEmail,
          ),

          hospitalDetailRow(
            Icons.location_on,
            'Address',
            hospitalAddress,
          ),

          const SizedBox(height: 12),

          // ==================================================
          // CAPACITY
          // ==================================================

          const Text(
            'Emergency Capacity',
            style: TextStyle(
              color: Colors.red,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [

              hospitalCapacity(
                Icons.bed,
                'Beds',
                availableBeds,
                Colors.blue,
              ),

              const SizedBox(width: 8),

              hospitalCapacity(
                Icons.monitor_heart,
                'ICU',
                icuBeds,
                Colors.red,
              ),

              const SizedBox(width: 8),

              hospitalCapacity(
                Icons.local_shipping,
                'Ambulance',
                ambulanceCount,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HOSPITAL DETAIL ROW
  // ============================================================

  Widget hospitalDetailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white54,
            size: 20,
          ),

          const SizedBox(width: 10),

          Text(
            '$title: ',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HOSPITAL CAPACITY
  // ============================================================

  Widget hospitalCapacity(
    IconData icon,
    String title,
    int value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius:
              BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),

            const SizedBox(height: 5),

            Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CONVERT FIRESTORE NUMBER
  // ============================================================

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

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
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed: () {
              setState(() {
                isLoading = true;
              });

              loadCitizenData();
            },
          ),
        ],
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: Colors.red,
              ),
            )
          : RefreshIndicator(
              color: Colors.red,
              onRefresh: loadCitizenData,

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
                    // WELCOME
                    // ==================================================

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(20),

                      decoration:
                          BoxDecoration(
                        gradient:
                            const LinearGradient(
                          colors: [
                            Colors.red,
                            Color(0xFF7A0000),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),

                      child: Row(
                        children: [

                          const CircleAvatar(
                            radius: 32,
                            backgroundColor:
                                Colors.white,
                            child: Icon(
                              Icons.person,
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

                                const Text(
                                  'Welcome back,',
                                  style: TextStyle(
                                    color:
                                        Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),

                                const SizedBox(
                                  height: 3,
                                ),

                                Text(
                                  fullName,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,

                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize: 23,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 3,
                                ),

                                const Text(
                                  'GuardianX Citizen',
                                  style: TextStyle(
                                    color:
                                        Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==================================================
                    // SOS BUTTON
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 85,

                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SosScreen(),
                            ),
                          );
                        },

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red,
                          foregroundColor:
                              Colors.white,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
                          ),
                        ),

                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,

                          children: const [
                            Icon(
                              Icons.warning_rounded,
                              size: 35,
                            ),

                            SizedBox(
                              width: 15,
                            ),

                            Text(
                              'EMERGENCY SOS',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    // ==================================================
                    // MY INFORMATION
                    // ==================================================

                    const Text(
                      'My Information',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 21,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

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

                    const SizedBox(
                      height: 20,
                    ),

                    // ==================================================
                    // EMERGENCY CONTACTS
                    // ==================================================

                    const Text(
                      'Emergency Contacts',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 21,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    emergencyCard(
                      title:
                          'Emergency Contact 1',
                      number:
                          emergencyContact1,
                    ),

                    emergencyCard(
                      title:
                          'Emergency Contact 2',
                      number:
                          emergencyContact2,
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==================================================
                    // HOSPITALS
                    // ==================================================

                    const Text(
                      'Registered Hospitals',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 21,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    const Text(
                      'Hospitals available through GuardianX',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    // ==================================================
                    // LOAD HOSPITALS
                    // ==================================================

                    StreamBuilder<
                        QuerySnapshot<
                            Map<String,
                                dynamic>>>(
                      stream:
                          FirebaseFirestore
                              .instance
                              .collection('users')
                              .where(
                                'role',
                                isEqualTo:
                                    'hospital',
                              )
                              .snapshots(),

                      builder:
                          (context, snapshot) {

                        if (snapshot
                            .connectionState ==
                            ConnectionState
                                .waiting) {
                          return const Center(
                            child:
                                Padding(
                              padding:
                                  EdgeInsets.all(
                                25,
                              ),
                              child:
                                  CircularProgressIndicator(
                                color:
                                    Colors.red,
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Container(
                            width:
                                double.infinity,
                            padding:
                                const EdgeInsets
                                    .all(20),
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFF1E1E1E,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                18,
                              ),
                            ),
                            child: Text(
                              'Unable to load hospitals:\n${snapshot.error}',
                              style:
                                  const TextStyle(
                                color:
                                    Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }

                        final hospitals =
                            snapshot.data?.docs ??
                                [];

                        if (hospitals.isEmpty) {
                          return Container(
                            width:
                                double.infinity,
                            padding:
                                const EdgeInsets
                                    .all(25),
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFF1E1E1E,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                18,
                              ),
                            ),
                            child:
                                const Column(
                              children: [
                                Icon(
                                  Icons
                                      .local_hospital_outlined,
                                  color:
                                      Colors.white38,
                                  size: 50,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'No hospitals registered yet',
                                  style:
                                      TextStyle(
                                    color:
                                        Colors.white70,
                                    fontSize:
                                        15,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children:
                              hospitals.map(
                            (hospital) {
                              return hospitalCard(
                                hospital,
                              );
                            },
                          ).toList(),
                        );
                      },
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==================================================
                    // FOOTER
                    // ==================================================

                    const Center(
                      child: Text(
                        'Your information is securely stored in GuardianX',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          color:
                              Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}