import 'package:flutter/material.dart';
import 'package:guardianx/screens/hospital/hospital_dashboard.dart';

class HospitalRegisterScreen extends StatefulWidget {
  const HospitalRegisterScreen({super.key});

  @override
  State<HospitalRegisterScreen> createState() => _HospitalRegisterScreenState();
}

class _HospitalRegisterScreenState extends State<HospitalRegisterScreen> {
  final TextEditingController hospitalNameController = TextEditingController();
  final TextEditingController hospitalIdController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController ambulanceController = TextEditingController();
  final TextEditingController bedsController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  String hospitalType = "Government";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Hospital Registration"),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.local_hospital, color: Colors.red, size: 90),

            const SizedBox(height: 20),

            const Text(
              "Create Hospital Account",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            buildField(
              hospitalNameController,
              "Hospital Name",
              Icons.local_hospital,
            ),

            buildField(hospitalIdController, "Hospital ID", Icons.badge),

            buildField(emailController, "Email", Icons.email),

            buildField(passwordController, "Password", Icons.lock, true),

            buildField(
              phoneController,
              "Emergency Contact Number",
              Icons.phone,
            ),

            buildField(
              addressController,
              "Hospital Address",
              Icons.location_city,
            ),

            buildField(
              ambulanceController,
              "Available Ambulances",
              Icons.local_shipping,
            ),

            buildField(bedsController, "Available Beds", Icons.bed),

            buildField(
              locationController,
              "Current Location",
              Icons.location_on,
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red),
              ),
              child: DropdownButton<String>(
                value: hospitalType,
                dropdownColor: Colors.black,
                isExpanded: true,
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(
                    value: "Government",
                    child: Text("Government Hospital"),
                  ),
                  DropdownMenuItem(
                    value: "Private",
                    child: Text("Private Hospital"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    hospitalType = value!;
                  });
                },
              ),
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
                      builder: (context) => const HospitalDashboard(),
                    ),
                  );
                },
                child: const Text(
                  "REGISTER",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildField(
    TextEditingController controller,
    String label,
    IconData icon, [
    bool isPassword = false,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.red),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey.shade900,
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
