
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AmbulanceDashboard extends StatefulWidget {
  const AmbulanceDashboard({super.key});

  @override
  State<AmbulanceDashboard> createState() =>
      _AmbulanceDashboardState();
}

class _AmbulanceDashboardState
    extends State<AmbulanceDashboard> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  bool isAvailable = true;
  bool loadingAvailability = false;

  User? get currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    loadAvailability();
  }

  Future<void> loadAvailability() async {
    final user = currentUser;
    if (user == null) return;

    try {
      final doc = await db.collection('users').doc(user.uid).get();
      if (!mounted) return;

      setState(() {
        isAvailable = doc.data()?['status'] != 'Busy';
      });
    } catch (e) {
      debugPrint('Could not load availability: $e');
    }
  }

  void showMessage(String message, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  // Update the logged-in ambulance driver's availability.
  Future<void> toggleAvailability() async {
    final user = currentUser;
    if (user == null || loadingAvailability) return;

    final newStatus = isAvailable ? 'Busy' : 'Available';

    setState(() => loadingAvailability = true);

    try {
      await db.collection('users').doc(user.uid).update({
        'status': newStatus,
      });

      if (!mounted) return;

      setState(() {
        isAvailable = newStatus == 'Available';
        loadingAvailability = false;
      });

      showMessage('Status updated: $newStatus');
    } catch (e) {
      if (!mounted) return;
      setState(() => loadingAvailability = false);
      showMessage('Unable to update status. Check Firestore rules.', error: true);
    }
  }

  // Emergency requests are created by SosScreen with status "active".
  // Also show requests accepted by this driver.
  Stream<QuerySnapshot<Map<String, dynamic>>> emergencyStream() {
    return db.collection('emergencies').snapshots();
  }

  bool belongsToThisDriver(Map<String, dynamic> data) {
    final user = currentUser;
    if (user == null) return false;

    return data['assignedAmbulanceId'] == user.uid;
  }

  bool isVisibleEmergency(Map<String, dynamic> data) {
    final status =
        (data['status'] ?? '').toString().toLowerCase();

    return status == 'active' ||
        (status == 'accepted' && belongsToThisDriver(data)) ||
        (status == 'responding' && belongsToThisDriver(data)) ||
        (status == 'arrived' && belongsToThisDriver(data));
  }

  // Atomically claim a request so two drivers cannot both accept
  // the same still-active emergency.
  Future<void> acceptEmergency(
    String emergencyId,
    Map<String, dynamic> data,
  ) async {
    final user = currentUser;
    if (user == null) {
      showMessage('Please sign in again.', error: true);
      return;
    }

    if (!isAvailable) {
      showMessage('Set your availability to Available first.', error: true);
      return;
    }

    try {
      await db.runTransaction((transaction) async {
        final ref = db.collection('emergencies').doc(emergencyId);
        final snapshot = await transaction.get(ref);

        if (!snapshot.exists) {
          throw Exception('This emergency no longer exists.');
        }

        final latest = snapshot.data() ?? {};
        final status =
            (latest['status'] ?? '').toString().toLowerCase();

        if (status != 'active') {
          throw Exception('This emergency has already been accepted.');
        }

        transaction.update(ref, {
          'status': 'accepted',
          'assignedAmbulanceId': user.uid,
          'assignedDriverName':
              user.displayName ?? 'Ambulance Driver',
          'acceptedAt': FieldValue.serverTimestamp(),
        });
      });

      await db.collection('users').doc(user.uid).update({
        'status': 'Busy',
      });

      if (!mounted) return;
      setState(() => isAvailable = false);
      showMessage('Emergency accepted successfully.');
    } catch (e) {
      showMessage(
        'Could not accept emergency: ${e.toString().replaceFirst('Exception: ', '')}',
        error: true,
      );
    }
  }

  Future<void> updateEmergencyStatus(
    String emergencyId,
    String newStatus,
  ) async {
    try {
      final user = currentUser;
      if (user == null) return;

      final ref = db.collection('emergencies').doc(emergencyId);
      final snapshot = await ref.get();

      if (!snapshot.exists) {
        showMessage('Emergency not found.', error: true);
        return;
      }

      final data = snapshot.data() ?? {};

      if (data['assignedAmbulanceId'] != user.uid) {
        showMessage('This emergency is not assigned to you.', error: true);
        return;
      }

      await ref.update({
        'status': newStatus,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });

      if (newStatus == 'resolved') {
        await db.collection('users').doc(user.uid).update({
          'status': 'Available',
        });

        if (mounted) setState(() => isAvailable = true);
      }

      showMessage('Emergency status updated: $newStatus');
    } catch (e) {
      showMessage(
        'Unable to update emergency. Check Firestore rules.',
        error: true,
      );
    }
  }

  Future<void> navigateToPatient(Map<String, dynamic> data) async {
    final lat = data['latitude'];
    final lng = data['longitude'];

    if (lat is! num || lng is! num) {
      showMessage('Patient GPS coordinates are not available.', error: true);
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${lat.toDouble()},${lng.toDouble()}'
      '&travelmode=driving',
    );

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        showMessage('Could not open navigation.', error: true);
      }
    } catch (e) {
      showMessage('Could not open navigation: $e', error: true);
    }
  }

  void showPatientDetails(
    String emergencyId,
    Map<String, dynamic> data,
  ) {
    final status = (data['status'] ?? 'active').toString().toLowerCase();
    final mine = belongsToThisDriver(data);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey.shade900,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Patient Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  detailRow('Name', data['userName']),
                  detailRow('Phone', data['phone']),
                  detailRow('Email', data['email']),
                  detailRow('Address', data['address']),
                  detailRow('Emergency Type', data['type']),
                  detailRow('Status', data['status']),
                  detailRow('Latitude', data['latitude']),
                  detailRow('Longitude', data['longitude']),
                  const SizedBox(height: 20),

                  if (data['latitude'] is num &&
                      data['longitude'] is num)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          navigateToPatient(data);
                        },
                        icon: const Icon(Icons.navigation),
                        label: const Text('Navigate to Patient'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                  if (status == 'active')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          acceptEmergency(emergencyId, data);
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Accept Emergency'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                  if (mine && status == 'accepted')
                    statusButton(
                      'Start Responding',
                      () {
                        Navigator.pop(sheetContext);
                        updateEmergencyStatus(
                          emergencyId,
                          'responding',
                        );
                      },
                    ),

                  if (mine && status == 'responding')
                    statusButton(
                      'Mark Arrived',
                      () {
                        Navigator.pop(sheetContext);
                        updateEmergencyStatus(
                          emergencyId,
                          'arrived',
                        );
                      },
                    ),

                  if (mine && status == 'arrived')
                    statusButton(
                      'Complete Emergency',
                      () {
                        Navigator.pop(sheetContext);
                        updateEmergencyStatus(
                          emergencyId,
                          'resolved',
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget statusButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        child: Text(label),
      ),
    );
  }

  Widget detailRow(String label, dynamic value) {
    final text = value == null || value.toString().trim().isEmpty
        ? 'Not provided'
        : value.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white60),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget dashboardCard(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap, {
    String? subtitle,
  }) {
    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 42, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showDriverSettings() async {
    final user = currentUser;
    if (user == null) return;

    try {
      final doc = await db.collection('users').doc(user.uid).get();
      final data = doc.data() ?? {};

      if (!mounted) return;

      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text(
            'Driver Settings',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              detailRow('Driver', data['driverName']),
              detailRow('Driver ID', data['driverId']),
              detailRow('Phone', data['phone']),
              detailRow('Ambulance', data['ambulanceNumber']),
              detailRow('Hospital', data['hospitalName']),
              detailRow('Location', data['currentLocation']),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await FirebaseAuth.instance.signOut();

                if (!mounted) return;

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      showMessage('Unable to load driver settings.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Please sign in to continue.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Ambulance Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh availability',
            onPressed: loadAvailability,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: emergencyStream(),
        builder: (context, snapshot) {
          final allDocs = snapshot.data?.docs ?? [];

          final requests = allDocs
              .where((doc) => isVisibleEmergency(doc.data()))
              .toList();

          requests.sort((a, b) {
            final aTime = a.data()['createdAtMillis'];
            final bTime = b.data()['createdAtMillis'];

            if (aTime is num && bTime is num) {
              return bTime.compareTo(aTime);
            }
            return 0;
          });

          final newRequests = requests.where((doc) {
            return (doc.data()['status'] ?? 'active') == 'active';
          }).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.grey.shade900,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 28,
                        child: Icon(
                          Icons.local_shipping,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ambulance Driver',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              isAvailable ? 'Available for requests' : 'Currently busy',
                              style: TextStyle(
                                color: isAvailable
                                    ? Colors.greenAccent
                                    : Colors.orangeAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isAvailable,
                        activeThumbColor: Colors.green,
                        onChanged: loadingAvailability
                            ? null
                            : (_) => toggleAvailability(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  dashboardCard(
                    Icons.notifications_active,
                    'Emergency Calls',
                    Colors.red,
                    () {
                      if (snapshot.hasError) {
                        showMessage(
                          'Unable to load emergencies. Check Firestore rules.',
                          error: true,
                        );
                      } else if (requests.isEmpty) {
                        showMessage('No emergency requests available.');
                      } else {
                        showMessage(
                          '$newRequests new request(s). See the list below.',
                        );
                      }
                    },
                    subtitle: '$newRequests new',
                  ),
                  dashboardCard(
                    Icons.location_on,
                    'Live Location',
                    Colors.blue,
                    () {
                      final doc = requests.cast<QueryDocumentSnapshot<Map<String, dynamic>>?>().firstWhere(
                        (d) => d != null &&
                            d.data()['latitude'] is num &&
                            d.data()['longitude'] is num,
                        orElse: () => null,
                      );

                      if (doc == null) {
                        showMessage('No patient location available.', error: true);
                      } else {
                        navigateToPatient(doc.data());
                      }
                    },
                  ),
                  dashboardCard(
                    Icons.navigation,
                    'Navigate',
                    Colors.green,
                    () {
                      final doc = requests.cast<QueryDocumentSnapshot<Map<String, dynamic>>?>().firstWhere(
                        (d) => d != null &&
                            d.data()['latitude'] is num &&
                            d.data()['longitude'] is num,
                        orElse: () => null,
                      );

                      if (doc == null) {
                        showMessage('No patient location available.', error: true);
                      } else {
                        navigateToPatient(doc.data());
                      }
                    },
                  ),
                  dashboardCard(
                    Icons.person,
                    'Patient Details',
                    Colors.orange,
                    () {
                      if (requests.isEmpty) {
                        showMessage('No patient details available.');
                      } else {
                        showPatientDetails(
                          requests.first.id,
                          requests.first.data(),
                        );
                      }
                    },
                  ),
                  dashboardCard(
                    Icons.check_circle,
                    'Availability',
                    Colors.purple,
                    toggleAvailability,
                    subtitle: isAvailable ? 'Available' : 'Busy',
                  ),
                  dashboardCard(
                    Icons.settings,
                    'Settings',
                    Colors.grey,
                    showDriverSettings,
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                'Emergency Requests',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: Colors.red),
                  ),
                )
              else if (snapshot.hasError)
                Card(
                  color: Colors.grey.shade900,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Could not load emergency requests.\n${snapshot.error}',
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                )
              else if (requests.isEmpty)
                Card(
                  color: Colors.grey.shade900,
                  child: const Padding(
                    padding: EdgeInsets.all(22),
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_none,
                          color: Colors.white38,
                          size: 48,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No Emergency Requests',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'New Citizen SOS requests will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...requests.map((doc) {
                  final data = doc.data();
                  final status =
                      (data['status'] ?? 'active').toString();
                  final mine = belongsToThisDriver(data);
                  final isNew = status.toLowerCase() == 'active';

                  return Card(
                    color: Colors.grey.shade900,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_rounded,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  data['type']?.toString() ?? 'SOS',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: isNew
                                      ? Colors.redAccent
                                      : Colors.orangeAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Patient: ${data['userName'] ?? 'Unknown'}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            'Phone: ${data['phone'] ?? 'Not provided'}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            'Address: ${data['address'] ?? 'Not provided'}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () =>
                                    showPatientDetails(doc.id, data),
                                icon: const Icon(Icons.person),
                                label: const Text('Details'),
                              ),
                              if (data['latitude'] is num &&
                                  data['longitude'] is num)
                                OutlinedButton.icon(
                                  onPressed: () => navigateToPatient(data),
                                  icon: const Icon(Icons.navigation),
                                  label: const Text('Navigate'),
                                ),
                              if (isNew)
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      acceptEmergency(doc.id, data),
                                  icon: const Icon(Icons.check),
                                  label: const Text('Accept'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              if (mine && status == 'accepted')
                                ElevatedButton(
                                  onPressed: () => updateEmergencyStatus(
                                    doc.id,
                                    'responding',
                                  ),
                                  child: const Text('Start Response'),
                                ),
                              if (mine && status == 'responding')
                                ElevatedButton(
                                  onPressed: () => updateEmergencyStatus(
                                    doc.id,
                                    'arrived',
                                  ),
                                  child: const Text('Arrived'),
                                ),
                              if (mine && status == 'arrived')
                                ElevatedButton(
                                  onPressed: () => updateEmergencyStatus(
                                    doc.id,
                                    'resolved',
                                  ),
                                  child: const Text('Complete'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
