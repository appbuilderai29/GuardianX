
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class SosServices {
  static Future<void> triggerSOS() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Please log in before sending SOS.');
    }

    // Check location permission.
    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Please enable your phone location.');
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is required for SOS.');
    }

    // Get the current location.
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    // Read the user's profile, if it exists.
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final profile = userDoc.data() ?? <String, dynamic>{};

    // Save the emergency to Firestore.
    await FirebaseFirestore.instance.collection('emergencies').add({
      'userId': user.uid,
      'userName': profile['name'] ?? user.displayName ?? 'Unknown',
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
  }
}
