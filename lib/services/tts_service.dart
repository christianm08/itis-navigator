import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servizio Text-to-Speech.
/// - Attende sempre che _init() sia completo prima di speak()
/// - Controlla se it-IT e' disponibile; se no, espone [italianAvailable] = false
///   cosi' l'UI puo' mostrare un avviso per installare la voce italiana.
class TtsService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  bool _enabled = true;
  bool _isSpeaking = false;
  bool _italianAvailable = true;

  late final Future<void> _ready;

  bool get enabled => _enabled;
  bool get isSpeaking => _isSpeaking;
  /// false se il motore it-IT non e' installato sul dispositivo
  bool get italianAvailable => _italianAvailable;

  String _lastSpoken = '';

  TtsService() {
    _ready = _init();
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rate = prefs.getDouble('tts_speech_rate') ?? 0.5;
      _enabled = prefs.getBool('tts_enabled') ?? true;

      // Controlla lingue disponibili
      final languages = await _tts.getLanguages as List?;
      final hasItalian = languages?.any((l) =>
              l.toString().toLowerCase().startsWith('it')) ??
          false;

      if (hasItalian) {
        await _tts.setLanguage('it-IT');
        _italianAvailable = true;
      } else {
        // Fallback inglese cosi' almeno si sente qualcosa
        await _tts.setLanguage('en-US');
        _italianAvailable = false;
        debugPrint('TTS: it-IT non disponibile, fallback en-US');
      }

      await _tts.setSpeechRate(rate);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
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

      notifyListeners();
      debugPrint(
          'TTS pronto — italiano: $_italianAvailable, rate: $rate, enabled: $_enabled');
    } catch (e) {
      debugPrint('TTS init fallito: $e');
    }
  }

  Future<void> speak(String text) async {
    if (!_enabled || text.isEmpty) return;
    await _ready;

    final cleaned = _cleanForSpeech(text);
    if (cleaned.isEmpty) return;
    if (cleaned == _lastSpoken) return;
    _lastSpoken = cleaned;

    try {
      await _tts.stop();
      await _tts.speak(cleaned);
    } catch (e) {
      debugPrint('TTS speak errore: $e');
    }
  }

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
