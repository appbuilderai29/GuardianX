import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:guardianx/screens/citizen/citizen_dashboard.dart';
class CitizenRegisterScreen extends StatefulWidget {
  const CitizenRegisterScreen({super.key});

  @override
  State<CitizenRegisterScreen> createState() =>
      _CitizenRegisterScreenState();
}

class _CitizenRegisterScreenState
    extends State<CitizenRegisterScreen> {

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final addressController = TextEditingController();
  final bloodController = TextEditingController();
  final emergency1Controller = TextEditingController();
  final emergency2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Citizen Registration"),
        backgroundColor: Colors.red,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            const Icon(
              Icons.person,
              size: 90,
              color: Colors.red,
            ),

            const SizedBox(height: 20),

            buildField(nameController,"Full Name"),
            buildField(phoneController,"Phone Number"),
            buildField(emailController,"Email"),
            buildField(passwordController,"Password"),
            buildField(addressController,"Address"),
            buildField(bloodController,"Blood Group"),
            buildField(emergency1Controller,"Emergency Contact 1"),
            buildField(emergency2Controller,"Emergency Contact 2"),

            const SizedBox(height:30),

            SizedBox(
              width: double.infinity,
              height:55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CitizenDashboard(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                child: const Text('Register'),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget buildField(
      TextEditingController controller,
      String label,
      ){

    return Padding(
      padding: const EdgeInsets.only(bottom:15),

      child: TextField(

        controller: controller,

        style: const TextStyle(color: Colors.white),

        decoration: InputDecoration(

          labelText: label,

          labelStyle: const TextStyle(color: Colors.white70),

          filled: true,

          fillColor: Colors.grey.shade900,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),

        ),
      ),
    );
  }
}