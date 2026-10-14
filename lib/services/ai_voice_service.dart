import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'voice_preferences_service.dart';

class AIVoiceService {
  AIVoiceService._();

  static final stt.SpeechToText _speech = stt.SpeechToText();

  static bool _initialized = false;
  static Completer<String?>? _resultCompleter;
  static Timer? _listenTimer;
  static String _latestWords = '';

  static bool get isListening => _speech.isListening;

  static Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      _initialized = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Voice status: $status');

          if (status == 'done' || status == 'notListening') {
            _finishListening();
          }
        },
        onError: (error) {
          debugPrint('Voice error: ${error.errorMsg}');
          _finishListening();
        },
      );

      return _initialized;
    } catch (e) {
      debugPrint('Voice initialization failed: $e');
      return false;
    }
  }

  static Future<String?> listen({
    String localeId = 'en_IN',
    Duration listenFor = const Duration(seconds: 10),
  }) async {
    final ready = await initialize();

    if (!ready) {
      throw Exception(
        'Speech recognition is unavailable. '
        'Check microphone permission and device support.',
      );
    }

    if (_speech.isListening) {
      await _speech.stop();
    }

    _listenTimer?.cancel();
    _resultCompleter = Completer<String?>();
    _latestWords = '';

    _listenTimer = Timer(listenFor, () async {
      if (_speech.isListening) {
        await _speech.stop();
      }
      _finishListening();
    });

    try {
      await _speech.listen(
        listenOptions: stt.SpeechListenOptions(
          localeId: localeId,
          listenFor: listenFor,
        ),
        onResult: (result) {
          _latestWords = result.recognizedWords.trim();

          if (result.finalResult) {
            _finishListening();
          }
        },
      );
    } catch (e) {
      _listenTimer?.cancel();
      _finishListening();
      rethrow;
    }

    return _resultCompleter!.future;
  }

  static void _finishListening() {
    _listenTimer?.cancel();

    final completer = _resultCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(_latestWords.isEmpty ? null : _latestWords);
    }
  }

  static Future<void> speak(String message) async {
    await VoicePreferencesService.speakEmergencyPrompt(message);
  }

  static Future<void> stopListening() async {
    _listenTimer?.cancel();

    if (_speech.isListening) {
      await _speech.stop();
    }

    _finishListening();
  }

  static Future<void> stopSpeaking() async {
    await VoicePreferencesService.stopSpeaking();
  }
}
