import 'package:flutter/material.dart';

class HospitalDashboard extends StatelessWidget {
  const HospitalDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Hospital Dashboard"),
        centerTitle: true,
      ),

      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,

        children: [

          dashboardCard(Icons.local_hospital, "Emergency Cases", Colors.red),

          dashboardCard(Icons.local_shipping, "Incoming Ambulances", Colors.orange),

          dashboardCard(Icons.bed, "Available Beds", Colors.green),

          dashboardCard(Icons.medical_services, "Doctors", Colors.blue),

          dashboardCard(Icons.people, "Patients", Colors.purple),

          dashboardCard(Icons.settings, "Settings", Colors.grey),

        ],
      ),
    );
  }

  Widget dashboardCard(
      IconData icon,
      String title,
      Color color,
      ) {

    return Card(
      color: Colors.grey.shade900,
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
                fontWeight: FontWeight.bold,
              ),
            )

          ],
        ),
      ),
    );
  }
}