
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:guardianx/firebase_options.dart';
import 'package:guardianx/screens/splash_screen.dart';
// ignore: unused_import
import 'package:guardianx/services/sos_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GuardianX());
}

class GuardianX extends StatelessWidget {
  const GuardianX({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GuardianX',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      
    );
  }
}

class TripleTapSOS extends StatefulWidget {
  final Widget child;

  const TripleTapSOS({
    super.key,
    required this.child,
  });

  @override
  State<TripleTapSOS> createState() => _TripleTapSOSState();
}

class _TripleTapSOSState extends State<TripleTapSOS> {
  int _tapCount = 0;
  DateTime? _lastTap;
  bool _handlingSOS = false;

  void _handleScreenTap() {
    if (_handlingSOS) return;

    final now = DateTime.now();

    if (_lastTap == null ||
        now.difference(_lastTap!) >
            const Duration(milliseconds: 1200)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }

    _lastTap = now;

    if (_tapCount >= 3) {
      _tapCount = 0;
      _lastTap = null;
      _confirmSOS();
    }
  }

  Future<void> _confirmSOS() async {
    if (_handlingSOS || !mounted) return;

    _handlingSOS = true;

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Emergency SOS'),
            content: const Text(
              'Three screen taps detected. '
              'Do you want to send an emergency alert?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('SEND SOS'),
              ),
            ],
          );
        },
      );

      if (confirmed == true && mounted) {
        await SosServices.triggerSOS();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('SOS request processed.'),
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not trigger SOS: $error'),
          ),
        );
      }
    } finally {
      _handlingSOS = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _handleScreenTap(),
      child: widget.child,
    );
  }
}
