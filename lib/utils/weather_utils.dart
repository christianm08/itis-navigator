/// Weather-related utilities
class WeatherUtils {
  WeatherUtils._();

  /// Convert WMO weather code to Italian description
  static String wmoDescription(int code) {
    if (code == 0) return 'Cielo sereno';
    if (code == 1) return 'Prevalentemente sereno';
    if (code == 2) return 'Parzialmente nuvoloso';
    if (code == 3) return 'Coperto';
    if (code <= 49) return 'Nebbia';
    if (code <= 57) return 'Pioggerella';
    if (code <= 67) return 'Pioggia';
    if (code <= 77) return 'Neve';
    if (code <= 82) return 'Acquazzoni';
    if (code <= 86) return 'Neve intensa';
    if (code <= 99) return 'Temporale';
    return 'Variabile';
  }

  /// Convert WMO weather code to emoji
  static String wmoEmoji(int code) {
    final isDay = DateTime.now().hour >= 6 && DateTime.now().hour < 20;
    if (code == 0) return isDay ? '☀️' : '🌙';
    if (code <= 2) return isDay ? '🌤️' : '🌙';
    if (code == 3) return '☁️';
    if (code <= 49) return '🌫️';
    if (code <= 67) return '🌧️';
    if (code <= 77) return '🌨️';
    if (code <= 82) return '🌦️';
    if (code <= 99) return '⛈️';
    return '🌤️';
  }

  /// Generate mock weather data based on time of day
  static MockWeatherData generateMockWeather() {
    final hour = DateTime.now().hour;
    return MockWeatherData(
      temperature: hour < 12 ? '14.5' : hour < 18 ? '18.2' : '13.0',
      description: hour < 20 ? 'Cielo sereno' : 'Notte serena',
      icon: hour < 20 ? '☀️' : '🌙',
      humidity: 72,
      windSpeed: 10.0,
    );
  }
}

/// Mock weather data structure
class MockWeatherData {
  final String temperature;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;

  const MockWeatherData({
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });
}
