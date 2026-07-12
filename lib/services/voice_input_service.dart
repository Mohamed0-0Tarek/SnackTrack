import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceInputService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _initialized = false;
  bool _isAvailable = false;

  bool get isAvailable => _isAvailable && _initialized;
  bool get isListening => _speech.isListening;

  final StreamController<String> _transcriptController =
      StreamController<String>.broadcast();
  String _transcript = '';

  Stream<String> get transcriptStream => _transcriptController.stream;
  String get transcript => _transcript;

  Future<bool> initialize() async {
    if (_initialized) return _isAvailable;
    try {
      _isAvailable = await _speech.initialize(
        onStatus: (status) => debugPrint('Voice status: $status'),
        onError: (e) => debugPrint('Voice error: $e'),
      );
      _initialized = true;
      return _isAvailable;
    } catch (e) {
      debugPrint('Failed to initialize voice: $e');
      return false;
    }
  }

  Future<void> startListening(String locale) async {
    if (!_isAvailable || !_initialized) return;
    _transcript = '';
    _transcriptController.add(_transcript);
    await _speech.listen(
      onResult: (result) {
        _transcript = result.recognizedWords;
        _transcriptController.add(_transcript);
      },
      listenOptions: stt.SpeechListenOptions(
        cancelOnError: true,
        partialResults: true,
        listenMode: stt.ListenMode.dictation,
        localeId: locale,
      ),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  void dispose() {
    _speech.cancel();
    _transcriptController.close();
  }
}
