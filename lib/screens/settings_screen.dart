import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Settings"),
      ),

      body: ListView(
        children: [

          ListTile(
            leading: const Icon(Icons.person, color: Colors.red),
            title: const Text(
              "Profile",
              style: TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {},
          ),

          const Divider(color: Colors.white24),

          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.orange),
            title: const Text(
              "Notifications",
              style: TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {},
          ),

          const Divider(color: Colors.white24),

          ListTile(
            leading: const Icon(Icons.security, color: Colors.green),
            title: const Text(
              "Privacy & Security",
              style: TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {},
          ),

          const Divider(color: Colors.white24),

          ListTile(
            leading: const Icon(Icons.info, color: Colors.blue),
            title: const Text(
              "About GuardianX",
              style: TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {},
          ),

          const Divider(color: Colors.white24),

          ListTile(
            leading: const Icon(Icons.help, color: Colors.purple),
            title: const Text(
              "Help & Support",
              style: TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}