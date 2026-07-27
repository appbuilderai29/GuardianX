import 'dart:async';
import 'package:flutter/material.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  bool isCounting = false;
  int countdown = 5;
  Timer? timer;

  void startSOS() {
    setState(() {
      isCounting = true;
      countdown = 5;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown == 1) {
        timer.cancel();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🚨 Emergency Alert Sent Successfully"),
            backgroundColor: Colors.red,
          ),
        );

        setState(() {
          isCounting = false;
        });

        // Firebase + Location + Call API will be added here later.
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }

  void cancelSOS() {
    timer?.cancel();

    setState(() {
      isCounting = false;
      countdown = 5;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          "SOS Emergency",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.warning_rounded,
              color: Colors.red,
              size: 90,
            ),

            const SizedBox(height: 20),

            const Text(
              "Emergency SOS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Press the button below to request immediate help.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 40),

            if (!isCounting)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(55),
                ),
                onPressed: startSOS,
                child: const Text(
                  "SOS",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

            if (isCounting)
              Column(
                children: [

                  Text(
                    "$countdown",
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Sending Emergency...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 25),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    onPressed: cancelSOS,
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}