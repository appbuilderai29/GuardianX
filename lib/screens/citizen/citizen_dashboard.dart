
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';

import 'package:guardianx/screens/citizen/gesture_sos_screen.dart';
import 'package:guardianx/services/voice_preferences_service.dart';
import 'package:guardianx/services/accident_detection_service.dart';

class CitizenDashboard extends StatefulWidget {
  const CitizenDashboard({super.key});

  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends State<CitizenDashboard> {
  static const MethodChannel _protectionChannel =
      MethodChannel('com.example.guardianx/back_tap');

  bool isLoading = true;
  bool _handlingSOS = false;
  bool _protectionEnabled = false;
  bool _protectionLoading = false;
  bool _accidentDetectionEnabled = false;

  String _selectedSosType = 'threat';
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
    _checkPendingGestureSOS();
    loadCitizenData();
    _syncProtectionState();
  }

  @override
  void dispose() {
    AccidentDetectionService.stop();
    super.dispose();
  }

  Future<void> _syncProtectionState() async {
    try {
      final running =
          await _protectionChannel.invokeMethod<bool>(
                'isProtectionRunning',
              ) ??
              false;

      if (mounted) {
        setState(() => _protectionEnabled = running);
      }
    } on PlatformException catch (e) {
      debugPrint('Protection state error: $e');
    } on MissingPluginException {
      debugPrint('Protection channel unavailable');
    }
  }

  Future<void> loadCitizenData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (mounted) setState(() => isLoading = false);
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      final data = doc.data() ?? {};

      setState(() {
        fullName =
            data['fullName']?.toString() ??
            user.displayName ??
            'Citizen';
        email = data['email']?.toString() ?? user.email ?? '';
        phone = data['phone']?.toString() ?? '';
        address = data['address']?.toString() ?? '';
        bloodGroup = data['bloodGroup']?.toString() ?? '';
        emergencyContact1 =
            data['emergencyContact1']?.toString() ?? '';
        emergencyContact2 =
            data['emergencyContact2']?.toString() ?? '';
        isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Load citizen data failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      setState(() => isLoading = false);
      _showMessage('Unable to load your information: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Three quick screen taps trigger Threat SOS.
  void _handleScreenTap() {
    if (_handlingSOS) return;

    final now = DateTime.now();

    if (_lastTap == null ||
        now.difference(_lastTap!) >
            const Duration(milliseconds: 1200)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }

    _lastTap = now;

    if (_tapCount >= 3) {
      _tapCount = 0;
      _lastTap = null;
      _confirmSOS(forcedType: 'threat');
    }
  }

  // The normal SOS button lets the user choose a type.
  // Automatic motion alerts pass forcedType: 'accident'.
  Future<void> _confirmSOS({String? forcedType}) async {
    if (_handlingSOS || !mounted) return;

    String selectedType = forcedType ?? 'threat';

    if (forcedType == null) {
      final selected = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Choose Emergency Type'),
                content: RadioGroup<String>(
                  groupValue: selectedType,
                  onChanged: (value) {
                    setDialogState(
                      () => selectedType = value ?? 'threat',
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      RadioListTile<String>(
                        title: Text('Threat / Personal Danger'),
                        subtitle: Text('Contact priority person'),
                        value: 'threat',
                      ),
                      RadioListTile<String>(
                        title: Text('Accident'),
                        subtitle: Text(
                          'Flag police and ambulance requirements',
                        ),
                        value: 'accident',
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(dialogContext),
                    child: const Text('CANCEL'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(
                      dialogContext,
                      selectedType,
                    ),
                    child: const Text('CONTINUE'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (selected == null || !mounted) return;
      selectedType = selected;
    }

    _selectedSosType = selectedType;
    _handlingSOS = true;

    int secondsLeft = 5;
    Timer? countdownTimer;

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              countdownTimer ??= Timer.periodic(
                const Duration(seconds: 1),
                (timer) {
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
                },
              );

              return AlertDialog(
                title: const Text('Confirm Emergency SOS'),
                content: Text(
                  'Emergency type: '
                  '${_selectedSosType.toUpperCase()}\n\n'
                  'SOS will be sent in $secondsLeft seconds.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      countdownTimer?.cancel();
                      countdownTimer = null;
                      Navigator.of(dialogContext).pop(false);
                    },
                    child: const Text('CANCEL SOS'),
                  ),
                ],
              );
            },
          );
        },
      );

      countdownTimer?.cancel();
      countdownTimer = null;

      if (confirmed == true && mounted) {
        await _sendSOS();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ SOS confirmation error: $e');
      debugPrintStack(stackTrace: stackTrace);
      _showMessage('Could not trigger SOS: $e');
    } finally {
      countdownTimer?.cancel();
      _handlingSOS = false;
    }
  }

  Future<void> _sendSOS() async {
    debugPrint('🚨 SOS: _sendSOS() started');

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint('❌ SOS FAILED: No logged-in user');
      _showMessage('Please log in before sending SOS.');
      return;
    }

    debugPrint('✅ SOS user ID: ${user.uid}');

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!await Geolocator.isLocationServiceEnabled()) {
        debugPrint('❌ SOS FAILED: Location service is disabled');
        _showMessage('Please enable location on your phone.');
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('❌ SOS FAILED: Location permission denied');
        _showMessage('Location permission is required.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      debugPrint('📍 SOS: Location obtained');

      final profile = userDoc.data() ?? {};
      final contact1 =
          profile['emergencyContact1']?.toString().trim() ?? '';
      final contact2 =
          profile['emergencyContact2']?.toString().trim() ?? '';
      final priorityContact =
          contact1.isNotEmpty ? contact1 : contact2;
      final isThreat = _selectedSosType == 'threat';

      debugPrint('🔥 SOS: Attempting Firestore write...');

      // Write the emergency record BEFORE attempting a phone call.
      final emergencyRef = await FirebaseFirestore.instance
          .collection('emergencies')
          .add({
        'userId': user.uid,
        'userName':
            profile['fullName'] ?? user.displayName ?? 'Citizen',
        'phone': profile['phone'] ?? '',
        'email': profile['email'] ?? user.email ?? '',
        'address': profile['address'] ?? '',
        'type': _selectedSosType,
        'status': 'active',
        'policeRequired': true,
        'ambulanceRequired': !isThreat,
        'emergencyContact1': contact1,
        'emergencyContact2': contact2,
        'priorityContact': priorityContact,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'createdAt': FieldValue.serverTimestamp(),
        'createdAtMillis':
            DateTime.now().millisecondsSinceEpoch,
      });

      debugPrint('✅ FIRESTORE WRITE SUCCESS');
      debugPrint('📄 Emergency document ID: ${emergencyRef.id}');

      // Show database success immediately after the write succeeds.
      _showMessage(
        'Emergency record saved. ID: ${emergencyRef.id}',
      );

      // Voice prompt plays on this phone.
      if (isThreat) {
        try {
          await VoicePreferencesService.speakEmergencyPrompt(
            'I am in danger. Please help me.',
          );
        } catch (e) {
          debugPrint('Emergency voice alert failed: $e');
        }
      }

      // A phone call is a separate operation from saving the record.
      if (priorityContact.isEmpty) {
        _showMessage(
          'Emergency saved, but no emergency contact is registered.',
        );
        return;
      }

      await _callPriorityContact(priorityContact);
    } catch (e, stackTrace) {
      debugPrint('❌ FIRESTORE/SOS ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
      _showMessage('SOS failed: $e');
    }
  }

  Future<void> _callPriorityContact(String number) async {
    final cleanedNumber =
        number.replaceAll(RegExp(r'[\s()-]'), '');

    if (cleanedNumber.isEmpty) return;

    try {
      final status = await Permission.phone.request();

      if (!status.isGranted) {
        _showMessage(
          'Emergency saved, but call permission was not granted.',
        );
        return;
      }

      final intent = AndroidIntent(
        action: 'android.intent.action.CALL',
        data: 'tel:$cleanedNumber',
      );

      await intent.launch();
    } catch (e, stackTrace) {
      debugPrint('❌ Priority contact call failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      _showMessage('Emergency saved, but the call could not start.');
    }
  }

  Future<void> _checkPendingGestureSOS() async {
    try {
      final pending =
          await _protectionChannel.invokeMethod<bool>(
                'getPendingGestureSOS',
              ) ??
              false;

      debugPrint('GESTURE SOS PENDING: $pending');

      if (!mounted || !pending) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const GestureSosScreen(),
        ),
      );

      await _protectionChannel.invokeMethod(
        'clearPendingGestureSOS',
      );
    } on PlatformException catch (e) {
      debugPrint('Gesture SOS error: ${e.message}');
    } on MissingPluginException {
      debugPrint('Gesture SOS channel unavailable');
    }
  }

  Future<void> _toggleProtection() async {
    if (_protectionLoading) return;

    setState(() => _protectionLoading = true);

    try {
      if (_protectionEnabled) {
        await _protectionChannel.invokeMethod('stopProtection');
        if (mounted) setState(() => _protectionEnabled = false);
      } else {
        await _protectionChannel.invokeMethod('startProtection');
        if (mounted) setState(() => _protectionEnabled = true);
      }
    } on PlatformException catch (e) {
      _showMessage('Protection error: ${e.message}');
    } on MissingPluginException {
      _showMessage('Protection service connection not found.');
    } finally {
      if (mounted) {
        setState(() => _protectionLoading = false);
      }
    }
  }

  Future<void> _toggleAccidentDetection() async {
    if (_accidentDetectionEnabled) {
      await AccidentDetectionService.stop();

      if (!mounted) return;
      setState(() => _accidentDetectionEnabled = false);
      _showMessage('Accident detection stopped.');
      return;
    }

    try {
      AccidentDetectionService.start(
        onPossibleAccident: () {
          if (!mounted || _handlingSOS) return;

          _showMessage(
            'Possible impact detected. Confirm the emergency.',
          );

          _confirmSOS(forcedType: 'accident');
        },
      );

      if (!mounted) {
        await AccidentDetectionService.stop();
        return;
      }

      setState(() => _accidentDetectionEnabled = true);
      _showMessage('Motion-based accident detection enabled.');
    } catch (e, stackTrace) {
      debugPrint('Accident detection start failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      _showMessage('Unable to start accident detection: $e');
    }
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
        title: Text(
          title,
          style: const TextStyle(color: Colors.white70),
        ),
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
        title: Text(
          title,
          style: const TextStyle(color: Colors.white70),
        ),
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

  Widget _hospitalCard(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
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
        centerTitle: true,
        title: const Text(
          'Citizen Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              loadCitizenData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _handleScreenTap(),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.red),
              )
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
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Welcome back,',
                                    style: TextStyle(
                                      color: Colors.white70,
                                    ),
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
                      SizedBox(
                        width: double.infinity,
                        height: 85,
                        child: ElevatedButton(
                          onPressed: () => _confirmSOS(),
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
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
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
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _toggleAccidentDetection,
                          icon: Icon(
                            _accidentDetectionEnabled
                                ? Icons.car_crash
                                : Icons.car_crash_outlined,
                          ),
                          label: Text(
                            _accidentDetectionEnabled
                                ? 'Stop Accident Detection'
                                : 'Start Accident Detection',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _accidentDetectionEnabled
                                    ? Colors.green
                                    : const Color(0xFF7A0000),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      _sectionTitle('My Information'),
                      _infoCard(Icons.person, 'Full Name', fullName),
                      _infoCard(Icons.email, 'Email', email),
                      _infoCard(Icons.phone, 'Phone Number', phone),
                      _infoCard(Icons.location_on, 'Address', address),
                      _infoCard(Icons.bloodtype, 'Blood Group', bloodGroup),
                      _sectionTitle('Emergency Contacts'),
                      _contactCard(
                        'Emergency Contact 1',
                        emergencyContact1,
                      ),
                      _contactCard(
                        'Emergency Contact 2',
                        emergencyContact2,
                      ),
                      _sectionTitle('Registered Hospitals'),
                      const Text(
                        'Hospitals available through GuardianX',
                        style: TextStyle(color: Colors.white60),
                      ),
                      const SizedBox(height: 14),
                      StreamBuilder<
                          QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('role', isEqualTo: 'hospital')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(
                              'Unable to load hospitals: '
                              '${snapshot.error}',
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

                          final hospitals =
                              snapshot.data?.docs ?? [];

                          if (hospitals.isEmpty) {
                            return const Text(
                              'No hospitals registered yet.',
                              style: TextStyle(color: Colors.white70),
                            );
                          }

                          return Column(
                            children:
                                hospitals.map(_hospitalCard).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Your information is securely stored in GuardianX',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
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
