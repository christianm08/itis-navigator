import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  bool _enabled = true;
  bool _isSpeaking = false;

  late final Future<void> _ready;

  bool get enabled => _enabled;
  bool get isSpeaking => _isSpeaking;

  TtsService() {
    _ready = _init();
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rate = prefs.getDouble('tts_speech_rate') ?? 0.5;
      _enabled = prefs.getBool('tts_enabled') ?? true;

      await _tts.setLanguage('it-IT');
      
      // Imposta voce italiana maschile
      final voices = await _tts.getVoices;
      if (voices is List) {
        final italianMaleVoice = voices.firstWhere(
          (voice) {
            final voiceMap = voice is Map ? voice : {};
            return voiceMap['locale'] == 'it-IT' && 
                   (voiceMap['gender'] == 'male' || 
                    voiceMap['name']?.toString().toLowerCase().contains('male') == true);
          },
          orElse: () => null,
        );
        if (italianMaleVoice != null) {
          await _tts.setVoice(italianMaleVoice);
        }
      }
      
      await _tts.setSpeechRate(rate);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);

      if (Platform.isAndroid) {
        await _tts.setEngine(await _tts.getDefaultEngine as String);
        await _tts.setSharedInstance(true);
      }

      if (Platform.isIOS) {
        await _tts.setSharedInstance(true);
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      }

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
      debugPrint('TTS pronto, rate: $rate, enabled: $_enabled');
    } catch (e) {
      debugPrint('TTS init fallito: $e');
    }
  }

  Future<void> speak(String text) async {
    if (!_enabled || text.isEmpty) return;
    await _ready;
    final cleaned = _cleanForSpeech(text);
    if (cleaned.isEmpty) return;
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
        .replaceAll(RegExp(r'\p{So}|\p{Cs}', unicode: true), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
