// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PoliceEmergenciesScreen extends StatefulWidget {
  const PoliceEmergenciesScreen({super.key});

  @override
  State<PoliceEmergenciesScreen> createState() =>
      _PoliceEmergenciesScreenState();
}

class _PoliceEmergenciesScreenState extends State<PoliceEmergenciesScreen> {
  final CollectionReference<Map<String, dynamic>> emergenciesCollection =
      FirebaseFirestore.instance.collection('emergencies');

  // ============================================================
  // UPDATE EMERGENCY STATUS
  // ============================================================

  Future<void> updateStatus(String documentId, String status) async {
    try {
      await emergenciesCollection.doc(documentId).update({
        'status': status,
        'statusUpdatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Emergency status changed to ${status.toUpperCase()}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update emergency: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final DateTime date = timestamp.toDate();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }

    return 'Unknown date';
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String formatTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final DateTime date = timestamp.toDate();

      final String hour = date.hour.toString().padLeft(2, '0');

      final String minute = date.minute.toString().padLeft(2, '0');

      return '$hour:$minute';
    }

    return 'Unknown time';
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'responding':
        return Colors.orange;

      case 'resolved':
        return Colors.green;

      case 'cancelled':
        return Colors.grey;

      default:
        return Colors.red;
    }
  }

  // ============================================================
  // EMERGENCY CARD
  // ============================================================

  Widget emergencyCard(String documentId, Map<String, dynamic> data) {
    final String citizenName =
        data['username']?.toString() ??
        data['fullName']?.toString() ??
        'Unknown Citizen';

    final String phone = data['phone']?.toString() ?? 'Not available';

    final String address = data['address']?.toString() ?? 'Not available';

    final String status = data['status']?.toString() ?? 'pending';

    final dynamic createdAt = data['createdAt'];

    final dynamic latitude = data['latitude'];

    final dynamic longitude = data['longitude'];

    return Card(
      color: const Color(0xFF1E1E1E),
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: statusColor(status).withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================
            Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.red,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EMERGENCY ALERT',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        // ignore: unnecessary_string_interpolations
                        '$citizenName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor(status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor(status),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(color: Colors.white12),

            const SizedBox(height: 12),

            // ==================================================
            // PHONE
            // ==================================================
            informationRow(Icons.phone, 'Phone', phone),

            const SizedBox(height: 10),

            // ==================================================
            // ADDRESS
            // ==================================================
            informationRow(Icons.location_on, 'Address', address),

            const SizedBox(height: 10),

            // ==================================================
            // DATE
            // ==================================================
            informationRow(Icons.calendar_today, 'Date', formatDate(createdAt)),

            const SizedBox(height: 10),

            // ==================================================
            // TIME
            // ==================================================
            informationRow(Icons.access_time, 'Time', formatTime(createdAt)),

            const SizedBox(height: 10),

            // ==================================================
            // GPS LOCATION
            // ==================================================
            informationRow(
              Icons.gps_fixed,
              'GPS',
              latitude != null && longitude != null
                  ? '$latitude, $longitude'
                  : 'Location unavailable',
            ),

            const SizedBox(height: 18),

            // ==================================================
            // ACTIONS
            // ==================================================
            if (status.toLowerCase() == 'pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        updateStatus(documentId, 'responding');
                      },
                      icon: const Icon(Icons.local_police),
                      label: const Text('RESPOND'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        updateStatus(documentId, 'cancelled');
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('CANCEL'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // ==================================================
            // RESPONDING
            // ==================================================
            if (status.toLowerCase() == 'responding')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    updateStatus(documentId, 'resolved');
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('MARK AS RESOLVED'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFORMATION ROW
  // ============================================================

  Widget informationRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.red, size: 20),

        const SizedBox(width: 10),

        Text(
          '$title: ',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),

        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
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
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,

        title: const Text(
          'Emergency Alerts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: emergenciesCollection
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          // ====================================================
          // ERROR
          // ====================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Unable to load emergencies',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ====================================================
          // LOADING
          // ====================================================

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          final documents = snapshot.data?.docs ?? [];

          // ====================================================
          // NO EMERGENCIES
          // ====================================================

          if (documents.isEmpty) {
            return RefreshIndicator(
              color: Colors.red,

              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 500));
              },

              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),

                children: const [
                  SizedBox(height: 180),

                  Icon(
                    Icons.notifications_none,
                    color: Colors.white38,
                    size: 70,
                  ),

                  SizedBox(height: 15),

                  Center(
                    child: Text(
                      'No emergency requests',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 8),

                  Center(
                    child: Text(
                      'New citizen SOS alerts will appear here.',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ),
                ],
              ),
            );
          }

          // ====================================================
          // EMERGENCY LIST
          // ====================================================

          return RefreshIndicator(
            color: Colors.red,

            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
            },

            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.all(16),

              itemCount: documents.length,

              itemBuilder: (context, index) {
                final document = documents[index];

                return emergencyCard(document.id, document.data());
              },
            ),
          );
        },
      ),
    );
  }
}
