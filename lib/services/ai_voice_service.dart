
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'voice_preferences_service.dart';

class AIVoiceService {
  AIVoiceService._();

  static final stt.SpeechToText _speech = stt.SpeechToText();

  static bool _initialized = false;

  static bool get isListening => _speech.isListening;

  static Future<bool> initialize() async {
    try {
      _initialized = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Voice status: $status');
        },
        onError: (error) {
          debugPrint('Voice error: ${error.errorMsg}');
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
    if (!_initialized) {
      final ready = await initialize();
      if (!ready) {
        throw Exception(
          'Speech recognition is unavailable. '
          'Check microphone permission and device support.',
        );
      }
    }

    if (_speech.isListening) {
      await _speech.stop();
    }

    String? recognizedText;

    await _speech.listen(
      // ignore: deprecated_member_use
      localeId: localeId,
      // ignore: deprecated_member_use
      listenFor: listenFor,
      onResult: (result) {
        if (result.finalResult) {
          recognizedText = result.recognizedWords.trim();
        }
      },
    );

    await Future<void>.delayed(listenFor);

    if (_speech.isListening) {
      await _speech.stop();
    }

    return recognizedText?.isEmpty == true ? null : recognizedText;
  }

  static Future<void> speak(String message) async {
    await VoicePreferencesService.speakEmergencyPrompt(message);
  }

  static Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  static Future<void> stopSpeaking() async {
    await VoicePreferencesService.stopSpeaking();
  }
}
