import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.red,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.red),
            title: Text(
              "No new notifications",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}