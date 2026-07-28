import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Removed import of firebase_options.dart because the file was not present.
// If you have platform-specific Firebase options, add the generated
// firebase_options.dart back to lib/ and restore the import.
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with default options. If you're targeting web or
  // have platform-specific options, restore the firebase_options import
  // and pass the options parameter here.
  await Firebase.initializeApp();

  runApp(const GuardianX());
}

class GuardianX extends StatelessWidget {
  const GuardianX({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GuardianX',
      home: const SplashScreen(),
    );
  }
}