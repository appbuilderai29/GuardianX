import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class SosServices {
  static Future<void> triggerSOS() async {
    final stopwatch = Stopwatch()..start();

    void logTime(String message) {
      debugPrint('SOS: $message (${stopwatch.elapsedMilliseconds} ms)');
    }

    logTime('Started');

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Please log in before sending SOS.');
    }

    // Check location service.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    logTime('Location service checked');

    if (!serviceEnabled) {
      throw Exception('Please enable your phone location.');
    }

    // Check permission.
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      logTime('Requesting location permission');
      permission = await Geolocator.requestPermission();
      logTime('Location permission response received');
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is required for SOS.');
    }

    // Start GPS retrieval and profile retrieval together.
    final locationFuture = () async {
      try {
        final lastKnownPosition = await Geolocator.getLastKnownPosition()
            .timeout(const Duration(seconds: 2));

        if (lastKnownPosition != null) {
          return lastKnownPosition;
        }
      } catch (e) {
        debugPrint('Cached location attempt failed: $e');
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    }();

    final profileFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    // Wait for both results.
    final results = await Future.wait([locationFuture, profileFuture]);

    final position = results[0] as Position;
    final userDoc = results[1] as DocumentSnapshot<Map<String, dynamic>>;
    final profile = userDoc.data() ?? <String, dynamic>{};

    logTime('GPS and profile retrieval completed');

    debugPrint('SOS AUTH UID: ${user.uid}');
    debugPrint('SOS PROFILE ROLE: ${profile['role']}');
    debugPrint('SOS PROFILE NAME: ${profile['fullName']}');
debugPrint('SOS PROFILE PHONE: ${profile['phone']}');
debugPrint('SOS PROFILE EMAIL: ${profile['email']}');
debugPrint('SOS AUTH EMAIL: ${user.email}');
    debugPrint('SOS DOCUMENT USER ID: ${user.uid}');
    debugPrint('SOS LATITUDE: ${position.latitude}');
    debugPrint('SOS LONGITUDE: ${position.longitude}');
    debugPrint('SOS GPS ACCURACY: ${position.accuracy}');
    debugPrint('SOS SERVICE VERSION: accuracy-field-check');
    // Save the emergency.
    try {
      logTime('Firebase write started');
      await FirebaseFirestore.instance.collection('emergencies').add({
        'userId': user.uid,
        'userName':
            profile['fullName'] ??
            profile['name'] ??
            user.displayName ??
            'Unknown',
        'phone': profile['phone'] ?? '',
        'email': user.email ?? '',
        'address': profile['address'] ?? '',
        'type': 'SOS',
        'status': 'active',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'locationAccuracyMeters': position.accuracy,
        'createdAt': FieldValue.serverTimestamp(),
        'createdAtMillis': DateTime.now().millisecondsSinceEpoch,
      });
      logTime('Firebase write completed');
    } on FirebaseException catch (e) {
      debugPrint('SOS FIREBASE ERROR: ${e.code}');
      debugPrint('SOS FIREBASE MESSAGE: ${e.message}');
      rethrow;
    }
  }
}
