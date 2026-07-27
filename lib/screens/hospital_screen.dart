import 'package:flutter/material.dart';

class HospitalScreen extends StatelessWidget {
  const HospitalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Nearby Hospitals"),
        backgroundColor: Colors.red,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [

            hospitalCard(
              "City Government Hospital",
              "2.3 km",
              Icons.local_hospital,
            ),

            hospitalCard(
              "Apollo Hospital",
              "4.8 km",
              Icons.local_hospital,
            ),

            hospitalCard(
              "Kauvery Hospital",
              "6.1 km",
              Icons.local_hospital,
            ),

            hospitalCard(
              "Emergency Medical Center",
              "7.4 km",
              Icons.local_hospital,
            ),

          ],
        ),
      ),
    );
  }

  Widget hospitalCard(
      String name,
      String distance,
      IconData icon,
      ) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "$distance away",
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text(
            "View",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}