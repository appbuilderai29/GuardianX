
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'emergency_location_screen.dart';

class PoliceEmergenciesScreen extends StatelessWidget {
  const PoliceEmergenciesScreen({super.key});

  final Color backgroundColor = const Color(0xFF101010);
  final Color cardColor = const Color(0xFF1D1D1D);

  String valueOf(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = '-',
  }) {
    for (final key in keys) {
      final value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

  DateTime? getCreatedAt(Map<String, dynamic> data) {
    final value =
        data['createdAt'] ?? data['timestamp'] ?? data['time'];

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  String formatDate(Map<String, dynamic> data) {
    final date = getCreatedAt(data);

    if (date == null) {
      return 'Time unavailable';
    }

    final localDate = date.toLocal();

    String twoDigits(int number) =>
        number.toString().padLeft(2, '0');

    return '${twoDigits(localDate.day)}/'
        '${twoDigits(localDate.month)}/'
        '${localDate.year} '
        '${twoDigits(localDate.hour)}:'
        '${twoDigits(localDate.minute)}';
  }

  Color statusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'active':
      case 'new':
      case 'pending':
        return Colors.redAccent;

      case 'in progress':
      case 'in_progress':
        return Colors.orangeAccent;

      case 'resolved':
      case 'closed':
        return Colors.greenAccent;

      default:
        return Colors.blueGrey;
    }
  }

  Map<String, dynamic> nestedLocationOf(
    Map<String, dynamic> data,
  ) {
    final value = data['location'];

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  double? parseCoordinate(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }

  Future<void> openLocation(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final nestedLocation = nestedLocationOf(data);

    final latitude = parseCoordinate(
      data['latitude'] ??
          data['lat'] ??
          nestedLocation['latitude'],
    );

    final longitude = parseCoordinate(
      data['longitude'] ??
          data['lng'] ??
          nestedLocation['longitude'],
    );

    final hasCoordinates = latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;

    final citizenName = valueOf(
      data,
      ['citizenName', 'fullName', 'name', 'userName'],
      fallback: 'Citizen',
    );

    if (hasCoordinates) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => EmergencyLocationScreen(
            latitude: latitude,
            longitude: longitude,
            citizenName: citizenName,
          ),
        ),
      );

      return;
    }

    final address = valueOf(
      data,
      ['address', 'locationAddress'],
      fallback: '',
    );

    if (address.trim().isEmpty || address == '-') {
      showMessage(
        context,
        'GPS coordinates and address are unavailable.',
      );
      return;
    }

    final uri = Uri.https(
      'www.google.com',
      '/maps/search/',
      {
        'api': '1',
        'query': address,
      },
    );

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        showMessage(context, 'Unable to open Google Maps.');
      }
    } catch (error) {
      debugPrint('Map opening error: $error');

      if (context.mounted) {
        showMessage(
          context,
          'Unable to open the emergency location.',
        );
      }
    }
  }

  Future<void> updateStatus(
    BuildContext context, {
    required String emergencyId,
    required String status,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage(context, 'Please log in again.');
      return;
    }

    try {
      final policeDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final role = (policeDocument.data()?['role'] ?? '')
          .toString()
          .trim()
          .toLowerCase();

      if (role != 'police') {
        if (context.mounted) {
          showMessage(
            context,
            'Only police accounts can update emergency status.',
          );
        }
        return;
      }

      await FirebaseFirestore.instance
          .collection('emergencies')
          .doc(emergencyId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': user.uid,
      });

      if (context.mounted) {
        showMessage(context, 'Status updated to $status.');
      }
    } on FirebaseException catch (error) {
      debugPrint('Firebase status update error: ${error.message}');

      if (context.mounted) {
        showMessage(
          context,
          'Could not update status. Check your Firestore rules.',
        );
      }
    } catch (error) {
      debugPrint('Status update error: $error');

      if (context.mounted) {
        showMessage(context, 'Something went wrong.');
      }
    }
  }

  static void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget statusButton(
    BuildContext context, {
    required String emergencyId,
    required String status,
    required IconData icon,
  }) {
    return OutlinedButton.icon(
      onPressed: () => updateStatus(
        context,
        emergencyId: emergencyId,
        status: status,
      ),
      icon: Icon(icon, size: 16),
      label: Text(status),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: statusColor(status)),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
      ),
    );
  }

  Widget emergencyCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    final citizenName = valueOf(
      data,
      ['citizenName', 'fullName', 'name', 'userName'],
      fallback: 'Unknown Citizen',
    );

    final phone = valueOf(
      data,
      ['phone', 'phoneNumber', 'mobile'],
    );

    final address = valueOf(
      data,
      ['address', 'locationAddress'],
    );

    final bloodGroup = valueOf(
      data,
      ['bloodGroup', 'blood_group'],
    );

    final status = valueOf(
      data,
      ['status'],
      fallback: 'active',
    );

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: statusColor(status).withValues(alpha: 0.65),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF421515),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        citizenName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Reported: ${formatDate(data)}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
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
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 28, color: Colors.white12),
            detailRow(Icons.phone, 'Phone', phone),
            detailRow(Icons.location_on, 'Address', address),
            detailRow(Icons.bloodtype, 'Blood Group', bloodGroup),
            detailRow(
              Icons.fingerprint,
              'Alert ID',
              document.id,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => openLocation(context, data),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Open Emergency Location'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(
                    color: Colors.redAccent,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                statusButton(
                  context,
                  emergencyId: document.id,
                  status: 'In Progress',
                  icon: Icons.local_police,
                ),
                statusButton(
                  context,
                  emergencyId: document.id,
                  status: 'Resolved',
                  icon: Icons.check_circle_outline,
                ),
                statusButton(
                  context,
                  emergencyId: document.id,
                  status: 'Closed',
                  icon: Icons.cancel_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget detailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.redAccent, size: 19),
          const SizedBox(width: 10),
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white60),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Emergency Alerts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh alerts',
            onPressed: () {
              // The Firestore stream refreshes automatically.
              showMessage(context, 'Emergency alerts are up to date.');
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<
            QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('emergencies')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Unable to load emergencies. Check your internet '
                    'connection and Firestore security rules.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.redAccent,
                ),
              );
            }

            final documents = snapshot.data?.docs.toList() ?? [];

            documents.sort((a, b) {
              final dateA = getCreatedAt(a.data());
              final dateB = getCreatedAt(b.data());

              if (dateA == null && dateB == null) return 0;
              if (dateA == null) return 1;
              if (dateB == null) return -1;

              return dateB.compareTo(dateA);
            });

            if (documents.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: Colors.white38,
                        size: 64,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No emergency alerts yet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'New SOS alerts will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${documents.length} emergency alert(s)',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                for (final document in documents)
                  emergencyCard(context, document),
              ],
            );
          },
        ),
      ),
    );
  }
}