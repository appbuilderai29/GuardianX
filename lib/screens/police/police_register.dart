import 'package:flutter/material.dart';
import 'package:guardianx/screens/police/police_dashboard.dart';

class PoliceRegisterScreen extends StatefulWidget {
  const PoliceRegisterScreen({super.key});

  @override
  State<PoliceRegisterScreen> createState() => _PoliceRegisterScreenState();
}

class _PoliceRegisterScreenState extends State<PoliceRegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController badgeController = TextEditingController();
  final TextEditingController stationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: const Text("Police Registration"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const Icon(Icons.local_police, size: 90, color: Colors.blue),

            const SizedBox(height: 15),

            const Text(
              "Police Officer Registration",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            buildField(
              controller: nameController,
              label: "Officer Name",
              icon: Icons.person,
            ),

            buildField(
              controller: badgeController,
              label: "Badge Number",
              icon: Icons.badge,
            ),

            buildField(
              controller: stationController,
              label: "Police Station",
              icon: Icons.local_police,
            ),

            buildField(
              controller: phoneController,
              label: "Phone Number",
              icon: Icons.phone,
            ),

            buildField(
              controller: emailController,
              label: "Email",
              icon: Icons.email,
            ),

            buildField(
              controller: passwordController,
              label: "Password",
              icon: Icons.lock,
              obscure: true,
            ),

            buildField(
              controller: locationController,
              label: "Current Location",
              icon: Icons.location_on,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),

                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PoliceDashboard(),
                    ),
                  );
                },

                child: const Text(
                  "REGISTER",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: TextField(
        controller: controller,
        obscureText: obscure,

        style: const TextStyle(color: Colors.white),

        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade900,

          prefixIcon: Icon(icon, color: Colors.red),

          labelText: label,

          labelStyle: const TextStyle(color: Colors.white70),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }
}
