import 'package:flutter/material.dart';

class EmergencyHistoryScreen extends StatelessWidget {
  const EmergencyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Emergency History"),
      ),
      body: const Center(
        child: Text(
          "No Emergency History",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}