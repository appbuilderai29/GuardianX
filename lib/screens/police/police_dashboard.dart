// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: unused_import
import 'police_emergencies_screen.dart';
class PoliceDashboard extends StatefulWidget {
  const PoliceDashboard({super.key});

  @override
  State<PoliceDashboard> createState() => _PoliceDashboardState();
}

class _PoliceDashboardState extends State<PoliceDashboard> {
  bool isLoading = true;

  String officerName = 'Police Officer';
  String badgeNumber = '-';
  String station = '-';
  String phone = '-';
  String email = '-';
  String location = '-';

  String policeStatus = 'Active';

  @override
  void initState() {
    super.initState();
    loadPoliceData();
  }

  // ============================================================
  // LOAD POLICE DATA
  // ============================================================

  Future<void> loadPoliceData() async {
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

      if (data == null) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      setState(() {
        officerName =
            data['officerName']?.toString() ??
            data['name']?.toString() ??
            'Police Officer';

        badgeNumber =
            data['badgeNumber']?.toString() ?? '-';

        station =
            data['policeStation']?.toString() ??
            data['station']?.toString() ??
            '-';

        phone =
            data['phone']?.toString() ?? '-';

        email =
            data['email']?.toString() ??
            user.email ??
            '-';

        location =
            data['currentLocation']?.toString() ??
            data['location']?.toString() ??
            '-';

        policeStatus =
            data['policeStatus']?.toString() ??
            'Active';

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
            'Unable to load police data: $e',
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
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
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
  // STATUS COLOR
  // ============================================================

  Color getStatusColor() {
    if (policeStatus.toLowerCase() == 'active') {
      return Colors.green;
    }

    if (policeStatus.toLowerCase() == 'busy') {
      return Colors.orange;
    }

    return Colors.red;
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
          'Police Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),

            onPressed: () {
              setState(() {
                isLoading = true;
              });

              loadPoliceData();
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

              onRefresh: loadPoliceData,

              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // ==================================================
                    // OFFICER HEADER
                    // ==================================================

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),

                        borderRadius:
                            BorderRadius.circular(20),

                        border: Border.all(
                          color: Colors.blue
                              .withValues(alpha: 0.5),
                        ),
                      ),

                      child: Row(
                        children: [
                          Container(
                            height: 70,
                            width: 70,

                            decoration: BoxDecoration(
                              color: Colors.blue
                                  .withValues(alpha: 0.15),

                              borderRadius:
                                  BorderRadius.circular(18),
                            ),

                            child: const Icon(
                              Icons.local_police,
                              color: Colors.blue,
                              size: 42,
                            ),
                          ),

                          const SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                Text(
                                  officerName,

                                  style:
                                      const TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  'Badge: $badgeNumber',

                                  style:
                                      const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  station,

                                  style:
                                      const TextStyle(
                                    color: Colors.white54,
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

                      decoration: BoxDecoration(
                        color: getStatusColor()
                            .withValues(alpha: 0.12),

                        borderRadius:
                            BorderRadius.circular(15),

                        border: Border.all(
                          color: getStatusColor(),
                        ),
                      ),

                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: getStatusColor(),
                            size: 14,
                          ),

                          const SizedBox(width: 10),

                          const Text(
                            'Police Status',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            policeStatus.toUpperCase(),

                            style: TextStyle(
                              color: getStatusColor(),
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // EMERGENCY ALERTS
                    // ==================================================

                    const Text(
                      'Emergency Alerts',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.all(25),

                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),

                        borderRadius:
                            BorderRadius.circular(18),

                        border: Border.all(
                          color: Colors.red
                              .withValues(alpha: 0.4),
                        ),
                      ),

                      child: Column(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: 55,
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'Emergency Monitoring',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            'Citizen SOS requests will appear here.',
                            textAlign: TextAlign.center,

                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,

                            child: ElevatedButton.icon(
                              onPressed: () {},

                              icon: const Icon(
                                Icons.location_on,
                              ),

                              label: const Text(
                                'VIEW EMERGENCY LOCATIONS',
                              ),

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
                                          12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // POLICE INFORMATION
                    // ==================================================

                    const Text(
                      'Officer Information',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    informationCard(
                      icon: Icons.person,
                      title: 'Officer Name',
                      value: officerName,
                      color: Colors.blue,
                    ),

                    informationCard(
                      icon: Icons.badge,
                      title: 'Badge Number',
                      value: badgeNumber,
                      color: Colors.orange,
                    ),

                    informationCard(
                      icon: Icons.local_police,
                      title: 'Police Station',
                      value: station,
                      color: Colors.purple,
                    ),

                    informationCard(
                      icon: Icons.phone,
                      title: 'Phone Number',
                      value: phone,
                      color: Colors.green,
                    ),

                    informationCard(
                      icon: Icons.email,
                      title: 'Email',
                      value: email,
                      color: Colors.orange,
                    ),

                    informationCard(
                      icon: Icons.location_on,
                      title: 'Current Location',
                      value: location,
                      color: Colors.red,
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // QUICK ACTIONS
                    // ==================================================

                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: actionButton(
                            Icons.people,
                            'Citizens',
                            Colors.green,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: actionButton(
                            Icons.assignment,
                            'Reports',
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: actionButton(
                            Icons.local_police,
                            'Patrol Units',
                            Colors.blue,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: actionButton(
                            Icons.notifications,
                            'Notifications',
                            Colors.amber,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget actionButton(
    IconData icon,
    String title,
    Color color,
  ) {
    return Container(
      height: 110,

      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: Colors.white12,
        ),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(18),

        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title selected'),
            ),
          );
        },

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              icon,
              color: color,
              size: 35,
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}