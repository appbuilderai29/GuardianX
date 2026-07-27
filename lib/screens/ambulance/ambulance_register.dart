import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:guardianx/screens/ambulance/ambulance_dashboard.dart';
class AmbulanceRegisterScreen extends StatefulWidget {
  const AmbulanceRegisterScreen({super.key});

  @override
  State<AmbulanceRegisterScreen> createState() =>
      _AmbulanceRegisterScreenState();
}

class _AmbulanceRegisterScreenState
    extends State<AmbulanceRegisterScreen> {

  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController driverIdController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController ambulanceNumberController =
      TextEditingController();
  final TextEditingController licenseController =
      TextEditingController();
  final TextEditingController hospitalController =
      TextEditingController();
  final TextEditingController locationController =
      TextEditingController();

  String status = "Available";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Ambulance Registration"),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const Icon(
              Icons.local_shipping,
              color: Colors.red,
              size: 90,
            ),

            const SizedBox(height: 20),

            const Text(
              "Create Ambulance Driver Account",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            buildField(
              driverNameController,
              "Driver Name",
              Icons.person,
            ),

            buildField(
              driverIdController,
              "Driver ID",
              Icons.badge,
            ),

            buildField(
              phoneController,
              "Phone Number",
              Icons.phone,
            ),

            buildField(
              emailController,
              "Email",
              Icons.email,
            ),

            buildField(
              passwordController,
              "Password",
              Icons.lock,
              true,
            ),

            buildField(
              ambulanceNumberController,
              "Ambulance Number",
              Icons.local_shipping,
            ),

            buildField(
              licenseController,
              "Driving License Number",
              Icons.credit_card,
            ),

            buildField(
              hospitalController,
              "Hospital Name",
              Icons.local_hospital,
            ),

            buildField(
              locationController,
              "Current Location",
              Icons.location_on,
            ),

            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red),
              ),
              child: DropdownButton<String>(
                value: status,
                dropdownColor: Colors.black,
                isExpanded: true,
                underline: const SizedBox(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Available",
                    child: Text("Available"),
                  ),
                  DropdownMenuItem(
                    value: "Busy",
                    child: Text("Busy"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    status = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AmbulanceDashboard(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "REGISTER",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
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
    IconData icon,
    [bool isPassword = false]
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: TextField(
        controller: controller,
        obscureText: isPassword,

        style: const TextStyle(color: Colors.white),

        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.red,
          ),

          labelText: label,

          labelStyle: const TextStyle(
            color: Colors.white70,
          ),

          filled: true,

          fillColor: Colors.grey.shade900,

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class AmbulanceDashboardScreen extends StatelessWidget {
  const AmbulanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambulance Dashboard'),
        backgroundColor: Colors.red,
      ),
      body: const Center(
        child: Text(
          'Ambulance Dashboard',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}