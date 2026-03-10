import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/local_api_keys.dart';

class WeatherService extends ChangeNotifier {
  bool _isLoading = false;
  String _temperature = '--';
  String _feelsLike = '--';
  String _description = 'Caricamento...';
  String _icon = '☁️';
  int _humidity = 0;
  double _windSpeed = 0.0;
  double _pressure = 0.0;
  double _rainRate = 0.0;

  bool get isLoading => _isLoading;
  String get temperature => _temperature;
  String get feelsLike => _feelsLike;
  String get description => _description;
  String get icon => _icon;
  int get humidity => _humidity;
  double get windSpeed => _windSpeed;
  double get pressure => _pressure;
  double get rainRate => _rainRate;

  // Coordinate ITIS Majorana - Cassino
  static const double _lat = 41.4897;
  static const double _lon = 13.8283;

  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  Future<void> fetchWeather() async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(
        '$_baseUrl'
        '?lat=$_lat'
        '&lon=$_lon'
        '&appid=${LocalApiKeys.openWeatherMapKey}'
        '&units=metric'
        '&lang=it',
      );

      debugPrint('🌤️ Fetching OpenWeatherMap: $url');

      final response =
          await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        final main = data['main'] as Map<String, dynamic>;
        final wind = data['wind'] as Map<String, dynamic>;
        final weatherList = data['weather'] as List<dynamic>;
        final weatherInfo = weatherList.first as Map<String, dynamic>;
        final rain = data['rain'] as Map<String, dynamic>?;

        _temperature = (main['temp'] as num).toStringAsFixed(1);
        _feelsLike = (main['feels_like'] as num).toStringAsFixed(1);
        _humidity = (main['humidity'] as num).toInt();
        _pressure = (main['pressure'] as num).toDouble();

        // OWM restituisce m/s, convertiamo in km/h
        _windSpeed = ((wind['speed'] as num).toDouble() * 3.6);

        // Pioggia ultima ora (opzionale)
        _rainRate = (rain?['1h'] as num?)?.toDouble() ?? 0.0;

        // Descrizione già in italiano grazie a lang=it
        _description = _capitalize(weatherInfo['description'] as String);
        _icon = _emojiFromOwmCode(
          weatherInfo['id'] as int,
          weatherInfo['icon'] as String,
        );

        debugPrint('✅ Meteo: ${_temperature}°C, $_description');
      } else if (response.statusCode == 401) {
        debugPrint('❌ API key OpenWeatherMap non valida');
        _useMockData();
      } else {
        debugPrint('❌ OWM error: ${response.statusCode}');
        _useMockData();
      }
    } catch (e) {
      debugPrint('❌ Errore meteo: $e');
      _useMockData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Converte il codice condizione OWM in emoji
  /// https://openweathermap.org/weather-conditions
  String _emojiFromOwmCode(int code, String icon) {
    final isNight = icon.endsWith('n');

    if (code == 800) return isNight ? '🌙' : '☀️';    // cielo sereno
    if (code == 801) return '🌤️';                     // poco nuvoloso
    if (code == 802) return '⛅';                      // nubi sparse
    if (code >= 803) return '☁️';                     // molto nuvoloso
    if (code >= 700) return '🌫️';                    // nebbia/foschia
    if (code >= 600) return '🌨️';                    // neve
    if (code >= 500) return '🌧️';                    // pioggia
    if (code >= 300) return '🌦️';                    // pioggerella
    if (code >= 200) return '⛈️';                    // temporale
    return '🌡️';
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  void _useMockData() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      _temperature = '14.5';
      _feelsLike = '13.2';
      _description = 'Sereno';
      _icon = '☀️';
      _humidity = 72;
      _windSpeed = 12.6;
    } else if (hour >= 12 && hour < 18) {
      _temperature = '18.2';
      _feelsLike = '17.5';
      _description = 'Cielo sereno';
      _icon = '☀️';
      _humidity = 60;
      _windSpeed = 7.2;
    } else {
      _temperature = '13.0';
      _feelsLike = '12.0';
      _description = 'Parzialmente nuvoloso';
      _icon = '🌤️';
      _humidity = 80;
      _windSpeed = 5.4;
    }
    _pressure = 1018.0;
    _rainRate = 0.0;
  }

  Future<void> getWeatherForCassino() async => fetchWeather();
}
