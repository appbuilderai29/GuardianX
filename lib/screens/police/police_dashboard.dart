
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'police_citizens_screen.dart';
import 'police_emergencies_screen.dart';

class PoliceDashboard extends StatefulWidget {
  const PoliceDashboard({super.key});

  @override
  State<PoliceDashboard> createState() => _PoliceDashboardState();
}

class _PoliceDashboardState extends State<PoliceDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  String? loadError;

  String officerName = 'Police Officer';
  String badgeNumber = '-';
  String policeStation = '-';
  String phone = '-';
  String email = '-';
  String location = '-';

  @override
  void initState() {
    super.initState();
    loadPoliceData();
  }

  Future<void> loadPoliceData() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Please sign in first.');
      }

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists || doc.data() == null) {
        throw Exception('Police profile not found.');
      }

      final data = doc.data()!;
      final role = (data['role'] ?? '').toString().toLowerCase();

      if (role != 'police') {
        throw Exception('This account is not a police account.');
      }

      if (!mounted) return;

      setState(() {
        officerName = _value(
          data,
          ['name', 'officerName', 'fullName'],
          user.displayName ?? 'Police Officer',
        );
        badgeNumber = _value(data, ['badgeNumber', 'badge'], '-');
        policeStation = _value(
          data,
          ['policeStation', 'station'],
          '-',
        );
        phone = _value(data, ['phone'], '-');
        email = _value(data, ['email'], user.email ?? '-');
        location = _value(data, ['location', 'currentLocation'], '-');
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        loadError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String _value(
    Map<String, dynamic> data,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = data[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return fallback;
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade900,
        ),
      );
  }

  void openScreen(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  void openEmergencyAlerts() {
    openScreen(const PoliceEmergenciesScreen());
  }

  void openLiveLocation() {
    // Open the emergency list; select an emergency to view its location.
    openEmergencyAlerts();
  }

  Future<void> callEmergencyNumber() async {
    final uri = Uri(scheme: 'tel', path: '112');

    try {
      if (!await launchUrl(uri)) {
        showMessage('Unable to open the phone dialer.');
      }
    } catch (_) {
      showMessage('Unable to open the phone dialer.');
    }
  }

  Widget dashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 27),
              ),
              const SizedBox(height: 9),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget emergencyAlertsCard() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('emergencies').snapshots(),
      builder: (context, snapshot) {
        var subtitle = 'Loading alerts...';

        if (snapshot.hasError) {
          subtitle = 'Unable to load alerts';
        } else if (snapshot.hasData) {
          final activeCount = snapshot.data!.docs.where((doc) {
            final status = (doc.data()['status'] ?? '')
                .toString()
                .toLowerCase()
                .trim();

            return status == 'active' ||
                status == 'pending' ||
                status == 'new';
          }).length;

          subtitle = '$activeCount active emergencies';
        }

        return dashboardCard(
          icon: Icons.warning_amber_rounded,
          title: 'Emergency Alerts',
          subtitle: subtitle,
          color: Colors.red,
          onTap: openEmergencyAlerts,
        );
      },
    );
  }

  Widget informationCard(String title, String value, IconData icon) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }

  Widget policeServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Police Services',
          style: TextStyle(
            color: Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.15,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            emergencyAlertsCard(),

            dashboardCard(
              icon: Icons.location_on,
              title: 'Live Location',
              subtitle: 'View emergency locations',
              color: Colors.blue,
              onTap: openLiveLocation,
            ),

            dashboardCard(
              icon: Icons.people,
              title: 'Citizens',
              subtitle: 'Citizen information',
              color: Colors.green,
              onTap: () => openScreen(
                const PoliceCitizensScreen(),
              ),
            ),

            dashboardCard(
              icon: Icons.assignment,
              title: 'Incident Reports',
              subtitle: 'Emergency records',
              color: Colors.orange,
              onTap: () => openScreen(
                const PoliceRecordsScreen(
                  title: 'Incident Reports',
                  collectionName: 'emergencies',
                ),
              ),
            ),

            dashboardCard(
              icon: Icons.local_police,
              title: 'Patrol Units',
              subtitle: 'View patrol records',
              color: Colors.purple,
              onTap: () => openScreen(
                const PoliceRecordsScreen(
                  title: 'Patrol Units',
                  collectionName: 'patrol_units',
                ),
              ),
            ),

            dashboardCard(
              icon: Icons.call,
              title: 'Emergency Calls',
              subtitle: 'Call emergency number',
              color: Colors.teal,
              onTap: callEmergencyNumber,
            ),

            dashboardCard(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Recent emergency records',
              color: Colors.amber,
              onTap: () => openScreen(
                const PoliceRecordsScreen(
                  title: 'Notifications',
                  collectionName: 'emergencies',
                ),
              ),
            ),

            dashboardCard(
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'View account information',
              color: Colors.grey,
              onTap: () => openScreen(
                PoliceSettingsScreen(
                  officerName: officerName,
                  badgeNumber: badgeNumber,
                  policeStation: policeStation,
                  phone: phone,
                  email: email,
                  location: location,
                  onRefresh: loadPoliceData,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Police Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: loadPoliceData,
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.red),
            )
          : loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          loadError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: loadPoliceData,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: Colors.red,
                  onRefresh: loadPoliceData,
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.red, Color(0xFF7A0000)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.local_police,
                                color: Colors.red,
                                size: 36,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Welcome back,',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  Text(
                                    officerName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    'Badge: $badgeNumber',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Police Information',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      informationCard(
                        'Officer Name',
                        officerName,
                        Icons.person,
                      ),
                      informationCard(
                        'Badge Number',
                        badgeNumber,
                        Icons.badge,
                      ),
                      informationCard(
                        'Police Station',
                        policeStation,
                        Icons.local_police,
                      ),
                      informationCard('Phone Number', phone, Icons.phone),
                      informationCard('Email', email, Icons.email),
                      informationCard(
                        'Location',
                        location,
                        Icons.location_on,
                      ),
                      const SizedBox(height: 18),
                      policeServices(),
                      const SizedBox(height: 28),
                      const Center(
                        child: Text(
                          'GuardianX Police Emergency Response System',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

// Displays records from a selected Firestore collection.
class PoliceRecordsScreen extends StatelessWidget {
  final String title;
  final String collectionName;

  const PoliceRecordsScreen({
    super.key,
    required this.title,
    required this.collectionName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(collectionName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Could not load records. Check Firestore security rules '
                  'and the collection name.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No records found.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              final name = data['citizenName'] ??
                  data['fullName'] ??
                  data['name'] ??
                  data['hospitalName'] ??
                  'Record ${index + 1}';

              final status = data['status'] ?? 'Registered';
              final phone = data['phone'] ?? data['citizenPhone'] ?? '-';
              final address =
                  data['address'] ?? data['location'] ?? '-';

              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: const Icon(
                    Icons.assignment,
                    color: Colors.red,
                  ),
                  title: Text(
                    name.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Status: $status',
                    style: const TextStyle(color: Colors.white60),
                  ),
                  iconColor: Colors.red,
                  collapsedIconColor: Colors.white70,
                  childrenPadding: const EdgeInsets.all(16),
                  children: [
                    _recordDetail('Phone', phone.toString()),
                    _recordDetail('Location', address.toString()),
                    _recordDetail('Record ID', doc.id),
                    if (data['latitude'] != null)
                      _recordDetail(
                        'Latitude',
                        data['latitude'].toString(),
                      ),
                    if (data['longitude'] != null)
                      _recordDetail(
                        'Longitude',
                        data['longitude'].toString(),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _recordDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54),
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
}

class PoliceSettingsScreen extends StatelessWidget {
  final String officerName;
  final String badgeNumber;
  final String policeStation;
  final String phone;
  final String email;
  final String location;
  final Future<void> Function() onRefresh;

  const PoliceSettingsScreen({
    super.key,
    required this.officerName,
    required this.badgeNumber,
    required this.policeStation,
    required this.phone,
    required this.email,
    required this.location,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(
            Icons.account_circle,
            color: Colors.red,
            size: 80,
          ),
          const SizedBox(height: 18),
          _setting('Officer Name', officerName),
          _setting('Badge Number', badgeNumber),
          _setting('Police Station', policeStation),
          _setting('Phone', phone),
          _setting('Email', email),
          _setting('Location', location),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              await onRefresh();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile refreshed.')),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Profile'),
          ),
        ],
      ),
    );
  }

  Widget _setting(String label, String value) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}