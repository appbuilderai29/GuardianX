import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA9vXbM9bVUEzsOB_d3NCj_XQ8UN1w8rqQ',
    appId: '1:924280192529:android:42d83a8b13946b6f95bbb0',
    messagingSenderId: '924280192529',
    projectId: 'guardianx-2026',
    storageBucket: 'guardianx-2026.firebasestorage.app',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDDnWxAn6J9fyX1mjOQ0-rZ8W1_iMzFn74',
    appId: '1:924280192529:web:8b66358ed3cd2efc95bbb0',
    messagingSenderId: '924280192529',
    projectId: 'guardianx-2026',
    authDomain: 'guardianx-2026.firebaseapp.com',
    storageBucket: 'guardianx-2026.firebasestorage.app',
    measurementId: 'G-4HBNEJDDQZ',
  );
}
