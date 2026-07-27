import 'package:flutter/material.dart';

// Import Registration Screens
import 'package:guardianx/screens/citizen/citizen_register.dart';
import 'package:guardianx/screens/ambulance/ambulance_register.dart';
import 'package:guardianx/screens/hospital/hospital_register.dart';
// ignore: unused_import
import 'package:guardianx/screens/police/police_register.dart' as police;

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Select Your Role"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 20),

            const Icon(Icons.security, size: 90, color: Colors.red),

            const SizedBox(height: 15),

            const Center(
              child: Text(
                "GuardianX",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Center(
              child: Text(
                "Choose your role to continue",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),

            const SizedBox(height: 35),

            roleCard(
              context,
              Icons.person,
              "Citizen",
              "Get emergency assistance",
              Colors.blue,
              const CitizenRegisterScreen(),
            ),

            const SizedBox(height: 15),

            roleCard(
              context,
              Icons.local_shipping,
              "Ambulance Driver",
              "Respond to emergency calls",
              Colors.red,
              const AmbulanceRegisterScreen(),
            ),

            const SizedBox(height: 15),

            roleCard(
              context,
              Icons.local_hospital,
              "Hospital",
              "Manage emergency patients",
              Colors.green,
              const HospitalRegisterScreen(),
            ),

            const SizedBox(height: 15),

            roleCard(
              context,
              Icons.local_police,
              "Police",
              "Respond to public threats",
              Colors.orange,
              const police.PoliceRegisterScreen() as Widget,
            ),
          ],
        ),
      ),
    );
  }

  Widget roleCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    Widget page,
  ) {
    return Card(
      color: const Color(0xFF1E1E1E),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}

class PoliceRegister {
  const PoliceRegister();
}
