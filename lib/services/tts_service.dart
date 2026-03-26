import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Servizio Text-to-Speech per le indicazioni vocali di navigazione.
///
/// Configurato per italiano, velocità moderata, e gestione coda:
/// ogni nuovo annuncio interrompe quello precedente per evitare
/// accumuli quando le istruzioni cambiano rapidamente.
class TtsService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  bool _enabled = true;
  bool _isSpeaking = false;
  bool _initialized = false;

  bool get enabled => _enabled;
  bool get isSpeaking => _isSpeaking;

  /// Ultimo testo pronunciato — evita di ripetere la stessa frase.
  String _lastSpoken = '';

  TtsService() {
    _init();
  }

  Future<void> _init() async {
    try {
      await _tts.setLanguage('it-IT');
      await _tts.setSpeechRate(0.5); // Velocità moderata, chiara
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      // Callback stato
      _tts.setStartHandler(() {
        _isSpeaking = true;
        notifyListeners();
      });

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });

      _tts.setCancelHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });

      _tts.setErrorHandler((msg) {
        debugPrint('⚠️ TTS errore: $msg');
        _isSpeaking = false;
        notifyListeners();
      });

      _initialized = true;
      debugPrint('🔊 TTS inizializzato (it-IT)');
    } catch (e) {
      debugPrint('⚠️ TTS init fallito: $e');
    }
  }

  /// Pronuncia il testo. Interrompe qualsiasi annuncio in corso.
  /// Non ripete lo stesso testo se chiamato più volte di fila.
  Future<void> speak(String text) async {
    if (!_enabled || !_initialized || text.isEmpty) return;

    // Pulisci emoji e caratteri speciali che il TTS leggerebbe male
    final cleaned = _cleanForSpeech(text);
    if (cleaned.isEmpty) return;

    // Evita ripetizioni consecutive
    if (cleaned == _lastSpoken) return;
    _lastSpoken = cleaned;

    try {
      await _tts.stop();
      await _tts.speak(cleaned);
    } catch (e) {
      debugPrint('⚠️ TTS speak errore: $e');
    }
  }

  /// Ferma la voce immediatamente.
  Future<void> stop() async {
    try {
      await _tts.stop();
      _isSpeaking = false;
      _lastSpoken = '';
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ TTS stop errore: $e');
    }
  }

  /// Abilita/disabilita la voce. Se disabilitata, ferma subito.
  void toggle() {
    _enabled = !_enabled;
    if (!_enabled) stop();
    notifyListeners();
  }

  /// Imposta lo stato abilitato/disabilitato.
  void setEnabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    if (!_enabled) stop();
    notifyListeners();
  }

  /// Rimuove emoji e simboli che il TTS pronuncerebbe in modo strano.
  String _cleanForSpeech(String text) {
    return text
        // Rimuovi emoji comuni
        .replaceAll(RegExp(r'[🎉🚌🏫📍⚠️🔴🟢✅❌🗺️🌦️🕐🌡️🧭🎯📏⬇️🔄📡🚏⏱️]'), '')
        // Rimuovi altri caratteri Unicode non-testo
        .replaceAll(RegExp(r'[\u{1F000}-\u{1FFFF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{2600}-\u{27BF}]'), '')
        // Pulisci spazi multipli
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
