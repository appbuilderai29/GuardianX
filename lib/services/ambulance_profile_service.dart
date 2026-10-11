
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AmbulanceProfileService {
  static Future<Map<String, dynamic>?> getDriverProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;

    final data = doc.data()!;

    if (data['role'] != 'ambulance' ||
        data['ambulanceRegistered'] != true) {
      return null;
    }

    return data;
  }
}
