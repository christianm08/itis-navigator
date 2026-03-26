import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servizio Text-to-Speech per le indicazioni vocali di navigazione.
/// Fix: _init() ora completa prima che speak() venga chiamato,
/// usando un Completer. La speech rate viene caricata da SharedPreferences.
class TtsService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  bool _enabled = true;
  bool _isSpeaking = false;

  // Future che si completa quando il motore TTS e' pronto
  late final Future<void> _ready;

  bool get enabled => _enabled;
  bool get isSpeaking => _isSpeaking;

  String _lastSpoken = '';

  TtsService() {
    _ready = _init();
  }

  Future<void> _init() async {
    try {
      // Carica preferenze salvate
      final prefs = await SharedPreferences.getInstance();
      final rate = prefs.getDouble('tts_speech_rate') ?? 0.5;
      _enabled = prefs.getBool('tts_enabled') ?? true;

      await _tts.setLanguage('it-IT');
      await _tts.setSpeechRate(rate);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      // Necessario su Android per usare il motore di sistema
      await _tts.awaitSpeakCompletion(false);

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
        debugPrint('TTS errore: $msg');
        _isSpeaking = false;
        notifyListeners();
      });

      debugPrint('TTS inizializzato (it-IT), rate: $rate, enabled: $_enabled');
    } catch (e) {
      debugPrint('TTS init fallito: $e');
    }
  }

  /// Pronuncia il testo. Attende che il motore sia pronto prima di parlare.
  Future<void> speak(String text) async {
    if (!_enabled || text.isEmpty) return;

    // Aspetta sempre che _init() sia completato
    await _ready;

    final cleaned = _cleanForSpeech(text);
    if (cleaned.isEmpty) return;

    // Evita ripetizioni consecutive
    if (cleaned == _lastSpoken) return;
    _lastSpoken = cleaned;

    try {
      await _tts.stop();
      await _tts.speak(cleaned);
    } catch (e) {
      debugPrint('TTS speak errore: $e');
    }
  }

  /// Aggiorna la speech rate a runtime e salva in SharedPreferences.
  Future<void> setSpeechRate(double rate) async {
    await _ready;
    await _tts.setSpeechRate(rate);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_speech_rate', rate);
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
      _isSpeaking = false;
      _lastSpoken = '';
      notifyListeners();
    } catch (e) {
      debugPrint('TTS stop errore: $e');
    }
  }

  void toggle() {
    _enabled = !_enabled;
    if (!_enabled) stop();
    notifyListeners();
  }

  void setEnabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    if (!_enabled) stop();
    notifyListeners();
  }

  String _cleanForSpeech(String text) {
    return text
        .replaceAll(RegExp(r'[\u{1F000}-\u{1FFFF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{2600}-\u{27BF}]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
