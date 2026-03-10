import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Meteo via Open-Meteo (https://open-meteo.com)
/// - Completamente gratuito, nessuna API key richiesta
/// - Aggiornato ogni ora da modelli meteorologici europei (DWD/ECMWF)
/// - Coordinate: ITIS Majorana Cassino (41.4897, 13.8283)
class WeatherService extends ChangeNotifier {
  bool _isLoading = false;
  String _temperature = '--';
  String _description = 'Caricamento...';
  String _icon = '☁️';
  int _humidity = 0;
  double _windSpeed = 0.0;

  bool get isLoading => _isLoading;
  String get temperature => _temperature;
  String get description => _description;
  String get icon => _icon;
  int get humidity => _humidity;
  double get windSpeed => _windSpeed;

  static const double _lat = 41.4897;
  static const double _lon = 13.8283;

  Future<void> fetchWeather() async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': '$_lat',
        'longitude': '$_lon',
        'current': [
          'temperature_2m',
          'relative_humidity_2m',
          'weather_code',
          'wind_speed_10m',
        ].join(','),
        'timezone': 'Europe/Rome',
        'forecast_days': '1',
      });

      debugPrint('🌤️ Open-Meteo: $url');

      final response =
          await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final cur = data['current'] as Map<String, dynamic>;

        _temperature =
            (cur['temperature_2m'] as num).toDouble().toStringAsFixed(1);
        _humidity =
            (cur['relative_humidity_2m'] as num?)?.toInt() ?? 0;
        _windSpeed =
            (cur['wind_speed_10m'] as num?)?.toDouble() ?? 0.0;

        final code = (cur['weather_code'] as num?)?.toInt() ?? 0;
        _description = _wmoDescription(code);
        _icon = _wmoEmoji(code);

        debugPrint('✅ Meteo: ${_temperature}°C, $_description (WMO $code)');
      } else {
        debugPrint('❌ Open-Meteo ${response.statusCode}');
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

  String _wmoDescription(int code) {
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

  String _wmoEmoji(int code) {
    final isDay =
        DateTime.now().hour >= 6 && DateTime.now().hour < 20;
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

  void _useMockData() {
    final h = DateTime.now().hour;
    _temperature = h < 12 ? '14.5' : h < 18 ? '18.2' : '13.0';
    _description = h < 20 ? 'Cielo sereno' : 'Notte serena';
    _icon = h < 20 ? '☀️' : '🌙';
    _humidity = 72;
    _windSpeed = 10.0;
  }

  Future<void> getWeatherForCassino() async => fetchWeather();
}
