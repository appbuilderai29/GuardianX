import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guardianx/services/sos_service.dart';

class GestureSosScreen extends StatefulWidget {
  const GestureSosScreen({super.key});

  @override
  State<GestureSosScreen> createState() => _GestureSosScreenState();
}

class _GestureSosScreenState extends State<GestureSosScreen> {
  static const int _initialSeconds = 60;

  int _secondsRemaining = _initialSeconds;
  Timer? _countdownTimer;

  bool _sending = false;
  bool _sent = false;
  bool _cancelled = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted || _sending || _sent || _cancelled) {
          timer.cancel();
          return;
        }

        if (_secondsRemaining <= 1) {
          timer.cancel();
          _sendSOS();
        } else {
          setState(() {
            _secondsRemaining--;
          });
        }
      },
    );
  }

  void _iAmSafe() {
    if (_sending || _sent) return;

    _countdownTimer?.cancel();

    setState(() {
      _cancelled = true;
    });

    Navigator.of(context).pop();
  }

  Future<void> _sendSOS() async {
    if (_sending || _sent || _cancelled) return;

    _countdownTimer?.cancel();

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
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_sending,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('GuardianX Emergency'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  _sent
                      ? 'Emergency Alert Created'
                      : 'Are You Safe?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _sent
                      ? 'Your emergency request was saved.'
                      : 'A possible emergency gesture was detected. '
                          'Confirm that you are safe before the timer ends.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                if (!_sent) ...[
                  const SizedBox(height: 28),
                  Text(
                    _formattedTime,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'TIME UNTIL SOS',
                    style: TextStyle(
                      color: Colors.white70,
                      letterSpacing: 2,
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Could not send SOS:\n$_error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The countdown has stopped. Try sending SOS again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
                const SizedBox(height: 30),
                if (!_sent)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: _sending ? null : _sendSOS,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        _sending ? 'SENDING SOS...' : 'SOS NOW',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: _sending
                        ? null
                        : (_sent
                            ? () => Navigator.of(context).pop()
                            : _iAmSafe),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                    child: Text(
                      _sent ? 'CLOSE' : 'I AM SAFE',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
