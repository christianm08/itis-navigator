import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WeatherService extends ChangeNotifier {
  bool _isLoading = false;
  String _temperature = '--';
  String _description = 'Caricamento...';
  String _icon = '☁️';
  int _humidity = 0;
  double _windSpeed = 0.0;
  double _pressure = 0.0;
  double _rainRate = 0.0;
  double _dewPoint = 0.0;

  bool get isLoading => _isLoading;
  String get temperature => _temperature;
  String get description => _description;
  String get icon => _icon;
  int get humidity => _humidity;
  double get windSpeed => _windSpeed;
  double get pressure => _pressure;
  double get rainRate => _rainRate;
  double get dewPoint => _dewPoint;

  // Coordinate Cassino (ITIS Majorana)
  static const double _lat = 41.4897;
  static const double _lon = 13.8283;

  // Open-Meteo: gratuito, nessuna API key, aggiornato ogni ora
  // Docs: https://open-meteo.com/en/docs
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<void> fetchWeather() async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(
        '$_baseUrl'
        '?latitude=$_lat'
        '&longitude=$_lon'
        '&current=temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m,surface_pressure,dew_point_2m'
        '&timezone=Europe%2FRome'
        '&forecast_days=1',
      );

      debugPrint('🌤️ Fetching weather from Open-Meteo: $url');

      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'] as Map<String, dynamic>;

        final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 0.0;
        _temperature = temp.toStringAsFixed(1);
        _humidity = (current['relative_humidity_2m'] as num?)?.toInt() ?? 0;
        _windSpeed = (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0;
        _pressure = (current['surface_pressure'] as num?)?.toDouble() ?? 0.0;
        _rainRate = (current['precipitation'] as num?)?.toDouble() ?? 0.0;
        _dewPoint = (current['dew_point_2m'] as num?)?.toDouble() ?? 0.0;

        final weatherCode = (current['weather_code'] as num?)?.toInt() ?? 0;
        _description = _descriptionFromCode(weatherCode);
        _icon = _iconFromCode(weatherCode);

        debugPrint('✅ Meteo aggiornato: ${_temperature}°C, $_description');
      } else {
        debugPrint('❌ Open-Meteo error: ${response.statusCode}');
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

  /// WMO Weather Codes -> descrizione italiana
  /// https://open-meteo.com/en/docs#weathervariables
  String _descriptionFromCode(int code) {
    if (code == 0) return 'Cielo sereno';
    if (code == 1) return 'Prevalentemente sereno';
    if (code == 2) return 'Parzialmente nuvoloso';
    if (code == 3) return 'Nuvoloso';
    if (code <= 49) return 'Nebbia';
    if (code <= 57) return 'Pioggerella';
    if (code <= 67) return 'Pioggia';
    if (code <= 77) return 'Neve';
    if (code <= 82) return 'Acquazzoni';
    if (code <= 86) return 'Neve abbondante';
    if (code <= 99) return 'Temporale';
    return 'Variabile';
  }

  /// WMO Weather Codes -> emoji
  String _iconFromCode(int code) {
    if (code == 0) {
      final h = DateTime.now().hour;
      return (h >= 6 && h < 20) ? '☀️' : '🌙';
    }
    if (code <= 2) return '🌤️';
    if (code == 3) return '☁️';
    if (code <= 49) return '🌫️';
    if (code <= 67) return '🌧️';
    if (code <= 77) return '🌨️';
    if (code <= 82) return '🌦️';
    if (code <= 99) return '⛈️';
    return '🌤️';
  }

  void _useMockData() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      _temperature = '14.5';
      _description = 'Prevalentemente sereno';
      _icon = '🌤️';
      _humidity = 72;
      _windSpeed = 3.5;
    } else if (hour >= 12 && hour < 18) {
      _temperature = '18.2';
      _description = 'Cielo sereno';
      _icon = '☀️';
      _humidity = 60;
      _windSpeed = 2.0;
    } else {
      _temperature = '13.0';
      _description = 'Parzialmente nuvoloso';
      _icon = '🌤️';
      _humidity = 80;
      _windSpeed = 1.5;
    }
    _pressure = 1018.0;
    _rainRate = 0.0;
    _dewPoint = 10.5;
  }

  Future<void> getWeatherForCassino() async {
    await fetchWeather();
  }
}
