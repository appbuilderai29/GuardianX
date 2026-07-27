import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("About GuardianX"),
        backgroundColor: Colors.red,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: const [

            Text(
              "GuardianX",
              style: TextStyle(
                color: Colors.red,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            Text(
              "GuardianX is an AI-powered emergency response application designed to provide quick assistance during accidents and emergencies.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),

            SizedBox(height: 25),

            Text(
              "Features",
              style: TextStyle(
                color: Colors.red,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            Text(
              "• SOS Emergency\n"
              "• Live Location\n"
              "• Ambulance Request\n"
              "• Police Assistance\n"
              "• Hospital Support\n"
              "• AI Accident Detection\n"
              "• Triple Tap Emergency\n"
              "• Voice Alert",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}