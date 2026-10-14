
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AccidentDetectionService {
  AccidentDetectionService._();

  static StreamSubscription<AccelerometerEvent>? _subscription;
  static DateTime? _lastAlert;
  static bool _enabled = false;

  static bool get isEnabled => _enabled;

  static void start({
    required VoidCallback onPossibleAccident,
  }) {
    if (_enabled) return;

    _enabled = true;

    _subscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(
      (event) {
        final now = DateTime.now();

        // Avoid repeated alerts from the same impact.
        if (_lastAlert != null &&
            now.difference(_lastAlert!) <
                const Duration(seconds: 20)) {
          return;
        }

        // Approximate total acceleration, including gravity.
        final magnitude = (event.x * event.x +
                event.y * event.y +
                event.z * event.z)
            .sqrt();

        // Prototype threshold; this is not a validated crash detector.
        if (magnitude > 25.0) {
          _lastAlert = now;
          debugPrint(
            'Possible impact detected: ${magnitude.toStringAsFixed(2)} m/s²',
          );
          onPossibleAccident();
        }
      },
      onError: (Object error) {
        debugPrint('Accelerometer error: $error');
      },
    );
  }

  static Future<void> stop() async {
    _enabled = false;
    await _subscription?.cancel();
    _subscription = null;
  }
}

extension on double {
  double sqrt() {
    // Newton's method for square root.
    if (this <= 0) return 0;
    double x = this;
    for (int i = 0; i < 10; i++) {
      x = (x + this / x) / 2;
    }
    return x;
  }
}
