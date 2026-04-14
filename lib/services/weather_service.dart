import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/app_strings.dart';
import '../constants/route_constants.dart';
import '../utils/weather_utils.dart';

/// Meteo via Open-Meteo (https://open-meteo.com)
/// - Completamente gratuito, nessuna API key richiesta
/// - Aggiornato ogni ora da modelli meteorologici europei (DWD/ECMWF)
/// - Coordinate: ITIS Majorana Cassino (41.4849, 13.8296)
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

  static const double _lat = AppStrings.cassinoLat;
  static const double _lon = AppStrings.cassinoLon;

  Future<void> fetchWeather() async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.https(RouteConstants.weatherBaseUrl, RouteConstants.weatherPath, {
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
          await http.get(url).timeout(const Duration(seconds: AppStrings.httpTimeoutSeconds));

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
        _description = WeatherUtils.wmoDescription(code);
        _icon = WeatherUtils.wmoEmoji(code);

        debugPrint('✅ Meteo: $_temperature°C, $_description (WMO $code)');
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

  void _useMockData() {
    final mock = WeatherUtils.generateMockWeather();
    _temperature = mock.temperature;
    _description = mock.description;
    _icon = mock.icon;
    _humidity = mock.humidity;
    _windSpeed = mock.windSpeed;
  }

  Future<void> getWeatherForCassino() async => fetchWeather();
}
