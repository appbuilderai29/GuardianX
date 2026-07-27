import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:guardianx/screens/splash_screen.dart';

Future<void> main() async {
  runApp(const GuardianX());
}

class GuardianX extends StatelessWidget {
  const GuardianX({super.key});

  @override
  Widget build(BuildContext context) {
    var materialApp = MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GuardianX',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
    return materialApp;
  }
}
