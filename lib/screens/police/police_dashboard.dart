import 'package:flutter/material.dart';

class PoliceDashboard extends StatelessWidget {
  const PoliceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Police Dashboard"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [

            dashboardCard(
              Icons.warning_amber,
              "Emergency Alerts",
              Colors.red,
            ),

            dashboardCard(
              Icons.location_on,
              "Live Location",
              Colors.blue,
            ),

            dashboardCard(
              Icons.people,
              "Citizens",
              Colors.green,
            ),

            dashboardCard(
              Icons.assignment,
              "Incident Reports",
              Colors.orange,
            ),

            dashboardCard(
              Icons.local_police,
              "Patrol Units",
              Colors.purple,
            ),

            dashboardCard(
              Icons.call,
              "Emergency Calls",
              Colors.teal,
            ),

            dashboardCard(
              Icons.notifications,
              "Notifications",
              Colors.amber,
            ),

            dashboardCard(
              Icons.settings,
              "Settings",
              Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboardCard(
    IconData icon,
    String title,
    Color color,
  ) {
    return Card(
      color: const Color(0xFF1E1E1E),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              size: 50,
              color: color,
            ),

            const SizedBox(height: 15),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),
      ),
    );
  }
}