
import 'package:flutter/material.dart';
import 'package:guardianx/services/sos_service.dart';

class GestureSosScreen extends StatefulWidget {
  const GestureSosScreen({super.key});

  @override
  State<GestureSosScreen> createState() => _GestureSosScreenState();
}

class _GestureSosScreenState extends State<GestureSosScreen> {
  bool _sending = false;
  bool _sent = false;
  String? _error;

  Future<void> _sendSOS() async {
    if (_sending || _sent) return;

    setState(() {
      _sending = true;
      _error = null;
    });

    try {
      await SosServices.triggerSOS();

      if (!mounted) return;
      setState(() {
        _sent = true;
        _sending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency alert saved successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _sending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GuardianX Emergency')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 72,
              ),
              const SizedBox(height: 16),
              Text(
                _sent
                    ? 'Emergency alert created'
                    : 'Possible SOS Gesture Detected',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                _sent
                    ? 'Your emergency record was saved to Firebase.'
                    : 'Confirm only if you need emergency assistance.',
                textAlign: TextAlign.center,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              if (!_sent)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _sending ? null : _sendSOS,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      _sending ? 'Sending...' : 'CONFIRM AND SEND SOS',
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _sending
                    ? null
                    : () => Navigator.of(context).pop(),
                child: Text(_sent ? 'Close' : 'Cancel — I am safe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
