import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoicePreferencesService {
  static final FlutterTts _tts = FlutterTts();

  static const Map<String, String> supportedLanguages = {
    'English': 'en-IN',
    'Tamil': 'ta-IN',
    'Hindi': 'hi-IN',
    'Telugu': 'te-IN',
    'Malayalam': 'ml-IN',
    'Kannada': 'kn-IN',
  };

  static DocumentReference<Map<String, dynamic>>? get _userDocument {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
  }

  static Future<Map<String, dynamic>> loadPreferences() async {
    final document = _userDocument;

    if (document == null) {
      throw Exception('Please log in to load voice preferences.');
    }

    final snapshot = await document.get();
    final data = snapshot.data() ?? <String, dynamic>{};

    final savedLanguage = data['preferredVoiceLanguage'];
    final language = supportedLanguages.containsKey(savedLanguage)
        ? savedLanguage as String
        : 'English';

    return {
      'preferredVoiceLanguage': language,
      'voiceEnabled': data['voiceEnabled'] is bool
          ? data['voiceEnabled'] as bool
          : true,
    };
  }

  static Future<void> savePreferences({
    required String language,
    required bool voiceEnabled,
  }) async {
    final document = _userDocument;

    if (document == null) {
      throw Exception('Please log in to save voice preferences.');
    }

    if (!supportedLanguages.containsKey(language)) {
      throw Exception('Unsupported voice language.');
    }

    await document.set({
      'preferredVoiceLanguage': language,
      'voiceEnabled': voiceEnabled,
    }, SetOptions(merge: true));
  }

  static Future<void> speakEmergencyPrompt(String message) async {
    final preferences = await loadPreferences();

    if (preferences['voiceEnabled'] != true) return;

    final language = preferences['preferredVoiceLanguage'] as String;
    final locale = supportedLanguages[language]!;

    final available = await _tts.isLanguageAvailable(locale);

    if (available != true) {
      throw Exception(
        'The selected voice language ($language) is not available '
        'on this device. Please install its speech voice or choose '
        'another supported language.',
      );
    }

    await _tts.setLanguage(locale);
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    await _tts.speak(message);
  }

  static Future<void> stopSpeaking() async {
    await _tts.stop();
  }
}
