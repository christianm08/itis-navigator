import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';

/// SharedPreferences utilities
class PrefsUtils {
  PrefsUtils._();

  /// Get SharedPreferences instance
  static Future<SharedPreferences> getInstance() => SharedPreferences.getInstance();

  /// Theme preferences
  static Future<bool> isDarkMode() async {
    final prefs = await getInstance();
    return prefs.getBool(AppStrings.prefsDarkMode) ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await getInstance();
    await prefs.setBool(AppStrings.prefsDarkMode, value);
  }

  /// Onboarding preferences
  static Future<bool> isOnboardingDone() async {
    final prefs = await getInstance();
    return prefs.getBool(AppStrings.prefsOnboardingDone) ?? false;
  }

  static Future<void> setOnboardingDone(bool value) async {
    final prefs = await getInstance();
    await prefs.setBool(AppStrings.prefsOnboardingDone, value);
  }

  /// TTS preferences
  static Future<bool> isTtsEnabled() async {
    final prefs = await getInstance();
    return prefs.getBool(AppStrings.prefsTtsEnabled) ?? true;
  }

  static Future<void> setTtsEnabled(bool value) async {
    final prefs = await getInstance();
    await prefs.setBool(AppStrings.prefsTtsEnabled, value);
  }

  static Future<double> getTtsSpeechRate() async {
    final prefs = await getInstance();
    return prefs.getDouble(AppStrings.prefsTtsSpeechRate) ?? 0.5;
  }

  static Future<void> setTtsSpeechRate(double value) async {
    final prefs = await getInstance();
    await prefs.setDouble(AppStrings.prefsTtsSpeechRate, value);
  }

  /// QR progress
  static Future<int> getQrProgress() async {
    final prefs = await getInstance();
    return prefs.getInt(AppStrings.prefsQrProgress) ?? 0;
  }

  static Future<void> setQrProgress(int value) async {
    final prefs = await getInstance();
    await prefs.setInt(AppStrings.prefsQrProgress, value);
  }

  /// Generic get
  static Future<T?> getValue<T>(String key, T? defaultValue) async {
    final prefs = await getInstance();
    return prefs.get(key) as T? ?? defaultValue;
  }

  /// Generic set
  static Future<void> setValue<T>(String key, T value) async {
    final prefs = await getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }
}
