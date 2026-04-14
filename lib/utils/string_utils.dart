import 'package:intl/intl.dart';

/// String manipulation and formatting utilities
class StringUtils {
  StringUtils._();

  /// Capitalize first letter of a string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Format time as HH:mm:ss
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  /// Format date in Italian locale
  static String formatDateItalian(DateTime dateTime) {
    return capitalize(
      DateFormat('EEEE, d MMMM yyyy', 'it_IT').format(dateTime),
    );
  }

  /// Clean text for TTS speech (remove emojis and extra whitespace)
  static String cleanForSpeech(String text) {
    return text
        .replaceAll(RegExp(r'\p{So}|\p{Cs}', unicode: true), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buongiorno';
    if (hour < 18) return 'Buon pomeriggio';
    return 'Buonasera';
  }

  /// Truncate text with ellipsis if longer than max length
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Remove all whitespace from string
  static String removeWhitespace(String text) {
    return text.replaceAll(RegExp(r'\s+'), '');
  }

  /// Get speech rate label for display
  static String getSpeechRateLabel(double r) {
    if (r <= 0.35) return 'Lenta';
    if (r <= 0.55) return 'Normale';
    return 'Veloce';
  }
}
