import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/foundation.dart';
// ignore: unused_import
import 'package:guardianx/services/location_service.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Emergency SOS"),
        backgroundColor: Colors.red,
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

            const SizedBox(height: 25),

            const Text(
              "EMERGENCY",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Press the button below to send an emergency alert.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () async {
                try {
                  final position = await LocationService.getCurrentLocation();
                  if (!mounted) return;
                  final messenger = ScaffoldMessenger.of(this.context);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        "SOS Sent!\nLat: ${position.latitude}\nLng: ${position.longitude}",
                      ),
                    ),
                  );
                  debugPrint("Latitude: ${position.latitude}");
                  debugPrint("Longitude: ${position.longitude}");
                } catch (e) {
                  if (!mounted) return;
                  final messenger = ScaffoldMessenger.of(this.context);
                  messenger.showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(60),
              ),
              child: const Text(
                "SOS",
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}