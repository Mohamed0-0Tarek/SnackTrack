import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceInputService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _initialized = false;
  bool _isAvailable = false;

  bool get isAvailable => _isAvailable && _initialized;
  bool get isListening => _speech.isListening;

  // Using a broadcast StreamController so multiple listeners can subscribe
  // (e.g. the widget listens AND the sheet button reads the final value).
  final StreamController<String> _transcriptController =
      StreamController<String>.broadcast();

  String _transcript = '';

  Stream<String> get transcriptStream => _transcriptController.stream;
  String get transcript => _transcript;

  Future<bool> initialize() async {
    if (_initialized) return _isAvailable;
    try {
      _isAvailable = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Voice status: $status');
          // When the engine reports 'done' or 'notListening', push the
          // final transcript one more time so the UI doesn't freeze on
          // the last partial result.
          if (status == 'done' || status == 'notListening') {
            _transcriptController.add(_transcript);
          }
        },
        onError: (e) {
          debugPrint('Voice error: $e');
          _transcriptController.addError(e.errorMsg);
        },
      );
      _initialized = true;
      return _isAvailable;
    } catch (e) {
      debugPrint('Failed to initialize voice: $e');
      return false;
    }
  }

  /// Starts listening and emits recognised words via [transcriptStream].
  ///
  /// The old version awaited [_speech.listen()] first, then subscribed to
  /// [transcriptStream]. On fast devices the first partial result arrived
  /// before the widget had subscribed, so the first word(s) were silently
  /// dropped. The callback now updates the internal field AND pushes to the
  /// controller immediately — the widget will receive every result as long
  /// as it has called [transcriptStream].listen() before this returns.
  Future<void> startListening(String locale) async {
    if (!_isAvailable || !_initialized) return;
    _transcript = '';
    _transcriptController.add(_transcript);

    await _speech.listen(
      onResult: (result) {
        _transcript = result.recognizedWords;
        // Emit on every partial AND final result so the UI stays in sync.
        if (!_transcriptController.isClosed) {
          _transcriptController.add(_transcript);
        }
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
