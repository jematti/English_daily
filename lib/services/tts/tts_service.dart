import 'package:flutter_tts/flutter_tts.dart';

class TtsUnavailableException implements Exception {
  const TtsUnavailableException();
}

class TtsService {
  TtsService({FlutterTts? flutterTts})
    : _flutterTts = flutterTts ?? FlutterTts();

  final FlutterTts _flutterTts;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.awaitSpeakCompletion(true);
    } on Object {
      throw const TtsUnavailableException();
    }

    _isInitialized = true;
  }

  Future<void> speakWord(String text) async {
    await _speak(text);
  }

  Future<void> speakSentence(String text) async {
    await _speak(text);
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } on Object {
      return;
    }
  }

  Future<void> _speak(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      return;
    }

    try {
      await init();
      await stop();
      final result = await _flutterTts.speak(trimmedText);
      if (result == 0) {
        throw const TtsUnavailableException();
      }
    } on TtsUnavailableException {
      rethrow;
    } on Object {
      throw const TtsUnavailableException();
    }
  }
}
