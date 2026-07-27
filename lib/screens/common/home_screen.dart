import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("GuardianX"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Welcome to GuardianX",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Your Smart Emergency Response System",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,

                children: [

                  homeCard(Icons.person, "Profile", Colors.blue),

                  homeCard(Icons.notifications, "Notifications", Colors.orange),

                  homeCard(Icons.settings, "Settings", Colors.green),

                  homeCard(Icons.info, "About", Colors.purple),

                  homeCard(Icons.logout, "Logout", Colors.red),

                ],
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget homeCard(
      IconData icon,
      String title,
      Color color,
      ) {

    return Card(
      color: Colors.grey.shade900,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(20),

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
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

          ],
        ),
      ),
    );
  }
}