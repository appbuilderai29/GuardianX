import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:guardianx/screens/citizen/sos_screen.dart';
// ignore: unused_import
import 'package:guardianx/screens/citizen/emergency_history_screen.dart';
// ignore: unused_import
import 'package:guardianx/screens/live_location_screen.dart';
// ignore: unused_import
import 'package:guardianx/screens/settings_screen.dart';

class CitizenDashboard extends StatelessWidget {
  const CitizenDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: const Text(
          "GuardianX",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.notifications, color: Colors.white),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome 👋",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),

            const SizedBox(height: 5),

            const Text(
              "Citizen",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            dashboardButton(
              context,
              Icons.warning,
              "SOS Emergency",
              Colors.red,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SosScreen()),
                );
              },
            ),
            dashboardButton(
              context,
              Icons.location_on,
              "Live Location",
              Colors.blue,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LiveLocationScreen(),
                  ),
                );
              },
            ),

            dashboardButton(
              context,
              Icons.contacts,
              "Emergency Contacts",
              Colors.orange,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Emergency Contacts coming soon!'),
                  ),
                );
              },
            ),

            dashboardButton(
              context,
              Icons.history,
              "Emergency History",
              Colors.green,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyHistoryScreen(),
                  ),
                );
              },
            ),
            dashboardButton(
              context,
              Icons.settings,
              "Settings",
              Colors.grey,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            dashboardButton(context, Icons.logout, "Logout", Colors.purple, () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }),
          ],
        ),
      ),
    );
  }

  Widget dashboardButton(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: InkWell(
        onTap: onTap,

        child: Container(
          height: 80,

          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color, width: 2),
          ),

          child: Row(
            children: [
              const SizedBox(width: 20),

              Icon(icon, color: color, size: 35),

              const SizedBox(width: 20),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Icon(Icons.arrow_forward_ios, color: Colors.white),

              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }
}
