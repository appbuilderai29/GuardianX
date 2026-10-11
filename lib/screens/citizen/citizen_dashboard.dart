import 'dart:async';
// ignore: unnecessary_import
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class CitizenDashboard extends StatefulWidget {
  const CitizenDashboard({super.key});

  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends State<CitizenDashboard> {
  bool isLoading = true;
  bool _handlingSOS = false;

  int _tapCount = 0;
  DateTime? _lastTap;

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
    _syncProtectionState();
  }

  // ignore: unused_element
  Future<void> _syncProtectionState() async {
    try {
      final bool running =
          await _protectionChannel.invokeMethod<bool>('isProtectionRunning') ??
          false;

      if (!mounted) return;

      setState(() {
        _protectionEnabled = running;
      });
    } on PlatformException {
      // Keep the current UI state if Android cannot be queried.
    } on MissingPluginException {
      // The native channel is unavailable.
    }
  }

  Future<void> loadCitizenData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (mounted) setState(() => isLoading = false);
        return;
      }

      final document = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      final data = document.data() ?? {};

      setState(() {
        fullName =
            data['fullName']?.toString() ?? user.displayName ?? 'Citizen';
        email = data['email']?.toString() ?? user.email ?? '';
        phone = data['phone']?.toString() ?? '';
        address = data['address']?.toString() ?? '';
        bloodGroup = data['bloodGroup']?.toString() ?? '';
        emergencyContact1 = data['emergencyContact1']?.toString() ?? '';
        emergencyContact2 = data['emergencyContact2']?.toString() ?? '';
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);
      _showMessage('Unable to load your information: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Detect three quick taps while the dashboard is visible.
  void _handleScreenTap() {
    if (_handlingSOS) return;

    final now = DateTime.now();

    if (_lastTap == null ||
        now.difference(_lastTap!) > const Duration(milliseconds: 1200)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }

    _lastTap = now;

    if (_tapCount >= 3) {
      _tapCount = 0;
      _lastTap = null;
      _confirmSOS();
    }
  }

  static const MethodChannel _protectionChannel = MethodChannel(
    'com.example.guardianx/back_tap',
  );

  bool _protectionEnabled = false;
  bool _protectionLoading = false;

  // ignore: unused_element
  Future<void> _toggleProtection() async {
    if (_protectionLoading) return;

    setState(() => _protectionLoading = true);

    try {
      if (_protectionEnabled) {
        await _protectionChannel.invokeMethod('stopProtection');
        setState(() => _protectionEnabled = false);
      } else {
        await _protectionChannel.invokeMethod('startProtection');
        setState(() => _protectionEnabled = true);
      }
    } on PlatformException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Protection error: ${e.message}')));
    } on MissingPluginException {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Protection service connection not found.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _protectionLoading = false);
      }
    }
  }

  Future<void> _confirmSOS() async {
    if (_handlingSOS || !mounted) return;

    _handlingSOS = true;
    bool cancelled = false;
    int secondsLeft = 5;
    Timer? countdownTimer;

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (
                timer,
              ) {
                if (secondsLeft <= 1) {
                  timer.cancel();
                  countdownTimer = null;

                  if (Navigator.of(dialogContext).canPop()) {
                    Navigator.of(dialogContext).pop(true);
                  }
                } else {
                  secondsLeft--;

                  setDialogState(() {});
                }
              });

              return AlertDialog(
                title: const Text('Emergency SOS'),
                content: Text(
                  'SOS will be sent in $secondsLeft seconds '
                  'unless you cancel.\n\n'
                  'Cancel if this was an accidental tap.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      cancelled = true;
                      countdownTimer?.cancel();
                      countdownTimer = null;
                      Navigator.of(dialogContext).pop(false);
                    },
                    child: const Text('CANCEL'),
                  ),
                ],
              );
            },
          );
        },
      );

      countdownTimer?.cancel();
      countdownTimer = null;

      if (confirmed == true && !cancelled && mounted) {
        await _sendSOS();
      }
    } catch (e) {
      _showMessage('Could not trigger SOS: $e');
    } finally {
      countdownTimer?.cancel();
      _handlingSOS = false;
    }
  }

  // Save an emergency record to Firestore.
  Future<void> _sendSOS() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please log in before sending SOS.');
      return;
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      _showMessage('Please enable location on your phone.');
      return;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showMessage('Location permission is required.');
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final profile = userDoc.data() ?? {};

    await FirebaseFirestore.instance.collection('emergencies').add({
      'userId': user.uid,
      'userName': profile['fullName'] ?? user.displayName ?? 'Citizen',
      'phone': profile['phone'] ?? '',
      'email': user.email ?? '',
      'address': profile['address'] ?? '',
      'type': 'SOS',
      'status': 'active',
      'latitude': position.latitude,
      'longitude': position.longitude,
      'createdAt': FieldValue.serverTimestamp(),
      'createdAtMillis': DateTime.now().millisecondsSinceEpoch,
    });

    _showMessage('SOS emergency record created.');
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white70)),
        subtitle: Text(
          value.isEmpty ? 'Not provided' : value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _contactCard(String title, String number) {
    return Card(
      color: const Color(0xFF2A1515),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.red),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.emergency, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white70)),
        subtitle: Text(
          number.isEmpty ? 'Not provided' : number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.phone, color: Colors.green),
      ),
    );
  }

  int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Widget _hospitalCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['hospitalName']?.toString() ?? 'Hospital',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hospital ID: ${data['hospitalId'] ?? '-'}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Type: ${data['hospitalType'] ?? '-'}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Phone: ${data['phone'] ?? '-'}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Address: ${data['address'] ?? '-'}',
              style: const TextStyle(color: Colors.white70),
            ),
            const Divider(color: Colors.white24),
            Text(
              'Beds: ${_toInt(data['availableBeds'])}   '
              'ICU: ${_toInt(data['icuBeds'])}   '
              'Ambulances: ${_toInt(data['ambulanceCount'])}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: const Text(
          'Citizen Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              loadCitizenData();
            },
          ),
        ],
      ),

      // The listener is inside Scaffold, so the dialog has
      // access to the app's Navigator.
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _handleScreenTap(),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.red))
            : RefreshIndicator(
                color: Colors.red,
                onRefresh: loadCitizenData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Welcome back,',
                                    style: TextStyle(color: Colors.white70),
                                  ),
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
                                  const Text(
                                    'GuardianX Citizen',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 85,
                        child: ElevatedButton(
                          onPressed: _confirmSOS,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning_rounded, size: 35),
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
                      ElevatedButton.icon(
                        onPressed: _protectionLoading
                            ? null
                            : _toggleProtection,
                        icon: Icon(
                          _protectionEnabled
                              ? Icons.shield
                              : Icons.shield_outlined,
                        ),
                        label: Text(
                          _protectionLoading
                              ? 'Please wait...'
                              : _protectionEnabled
                              ? 'Stop Protection'
                              : 'Start Protection',
                        ),
                      ),

                      _sectionTitle('My Information'),
                      _infoCard(Icons.person, 'Full Name', fullName),
                      _infoCard(Icons.email, 'Email', email),
                      _infoCard(Icons.phone, 'Phone Number', phone),
                      _infoCard(Icons.location_on, 'Address', address),
                      _infoCard(Icons.bloodtype, 'Blood Group', bloodGroup),

                      _sectionTitle('Emergency Contacts'),
                      _contactCard('Emergency Contact 1', emergencyContact1),
                      _contactCard('Emergency Contact 2', emergencyContact2),

                      _sectionTitle('Registered Hospitals'),
                      const Text(
                        'Hospitals available through GuardianX',
                        style: TextStyle(color: Colors.white60),
                      ),
                      const SizedBox(height: 14),

                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('role', isEqualTo: 'hospital')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(
                              'Unable to load hospitals: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.red,
                              ),
                            );
                          }

                          final hospitals = snapshot.data?.docs ?? [];

                          if (hospitals.isEmpty) {
                            return const Text(
                              'No hospitals registered yet.',
                              style: TextStyle(color: Colors.white70),
                            );
                          }

                          return Column(
                            children: hospitals.map(_hospitalCard).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Your information is securely stored in GuardianX',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
