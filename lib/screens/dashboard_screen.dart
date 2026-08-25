import 'package:flutter/material.dart';
import 'package:guardianx/screens/citizen/sos_screen.dart';
// ignore: unused_import

import 'package:guardianx/screens/emergency_contact_screen.dart';
import 'package:guardianx/screens/live_location_screen.dart';
import 'package:guardianx/screens/ambulance_screen.dart';
import 'package:guardianx/screens/hospital_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        title: const Text(
          'GuardianX',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome!",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  "Your Safety Companion",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Stay Safe • Stay Connected",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          dashboardTile(
            context,
            Icons.warning,
            'SOS Emergency',
            'Tap to send emergency alert',
            Colors.red,
          ),

          dashboardTile(
            context,
            Icons.location_on,
            'Live Location',
            'Share your current location',
            Colors.blue,
          ),
          dashboardTile(
            context,
            Icons.contacts,
            'Emergency Contacts',
            'Manage your emergency contacts',
            Colors.green,
          ),

          dashboardTile(
            context,
            Icons.local_shipping,
            'Request Ambulance',
            'Call the nearest ambulance',
            Colors.orange,
          ),

          dashboardTile(
            context,
            Icons.local_hospital,
            'Nearby Hospitals',
            'Find nearby hospitals',
            Colors.purple,
          ),

          dashboardTile(
            context,
            Icons.security,
            'Threat Alert',
            'Report unsafe situations',
            Colors.redAccent,
          ),

          dashboardTile(
            context,
            Icons.history,
            'Emergency History',
            'View previous alerts',
            Colors.grey,
          ),

          dashboardTile(
            context,
            Icons.settings,
            'Settings',
            'Manage your profile and app',
            Colors.blueGrey,
          ),
          // More dashboard tiles...
        ],
      ),
    );
  }

  Widget dashboardTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Card(
      color: const Color.fromARGB(255, 121, 6, 6),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, size: 32, color: color),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        onTap: () {
          if (title == 'SOS Emergency') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SosScreen()),
            );
          } else if (title == 'Emergency Contacts') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EmergencyContactScreen(),
              ),
            );
          } else if (title == 'Live Location') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LiveLocationScreen(),
              ),
            );
          } else if (title == 'Request Ambulance') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AmbulanceScreen()),
            );
          } else if (title == 'Nearby Hospitals') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HospitalScreen()),
            );
          }
        },
      ),
    );
  }
}

// ignore: camel_case_types
class sosscreen {
  const sosscreen();
}
