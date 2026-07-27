import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.red,
      ),
      body: ListView(
        children: const [

          ListTile(
            leading: Icon(Icons.lock,color: Colors.red),
            title: Text(
              "Change Password",
              style: TextStyle(color: Colors.white),
            ),
          ),

          Divider(),

          ListTile(
            leading: Icon(Icons.language,color: Colors.red),
            title: Text(
              "Language",
              style: TextStyle(color: Colors.white),
            ),
          ),

          Divider(),

          ListTile(
            leading: Icon(Icons.dark_mode,color: Colors.red),
            title: Text(
              "Dark Mode",
              style: TextStyle(color: Colors.white),
            ),
          ),

          Divider(),

          ListTile(
            leading: Icon(Icons.logout,color: Colors.red),
            title: Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}