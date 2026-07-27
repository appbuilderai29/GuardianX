import 'package:flutter/material.dart';

class AmbulanceDashboard extends StatelessWidget {
  const AmbulanceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Ambulance Dashboard"),
        centerTitle: true,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        children: [
          dashboardCard(
            Icons.notifications_active,
            "Emergency Calls",
            Colors.red,
          ),
          dashboardCard(Icons.location_on, "Live Location", Colors.blue),
          dashboardCard(Icons.navigation, "Navigate", Colors.green),
          dashboardCard(Icons.person, "Patient Details", Colors.orange),
          dashboardCard(Icons.check_circle, "Availability", Colors.purple),
          dashboardCard(Icons.settings, "Settings", Colors.grey),
        ],
      ),
    );
  }

  Widget dashboardCard(IconData icon, String title, Color color) {
    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
