import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/local_api_keys.dart';

class WeatherService extends ChangeNotifier {
  bool _isLoading = false;
  String _temperature = '--';
  String _description = 'Caricamento...';
  String _icon = '☀️';
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

  // Stazione meteorologica ITIS Majorana - Cassino
  static const String _stationCode = 'laz543';

  Future<void> fetchWeather() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Se il token non è configurato, usa dati mock
      if (LocalApiKeys.meteoNetworkToken == 'YOUR_METEONETWORK_TOKEN') {
        debugPrint('⚠️ Token MeteoNetwork non configurato, uso dati mock');
        _useMockData();
        return;
      }

      // Endpoint MeteoNetwork per dati real-time della stazione LAZ543
      final url = Uri.parse(
        'https://api.meteonetwork.it/v3/data-realtime/$_stationCode',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${LocalApiKeys.meteoNetworkToken}',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        if (data.isNotEmpty) {
          final stationData = data[0];
          
          // Dati dalla stazione ITIS
          _temperature = stationData['temperature']?.toStringAsFixed(1) ?? '--';
          _humidity = stationData['rh']?.toInt() ?? 0;
          _windSpeed = stationData['wind_speed']?.toDouble() ?? 0.0;
          _pressure = stationData['smlp']?.toDouble() ?? 0.0;
          _rainRate = stationData['rain_rate']?.toDouble() ?? 0.0;
          _dewPoint = stationData['dew_point']?.toDouble() ?? 0.0;
          
          // Descrizione automatica basata sui dati
          _description = _generateDescription();
          _icon = _getWeatherIcon();
          
          debugPrint('✅ Dati meteo ricevuti dalla stazione ITIS LAZ543');
        } else {
          throw Exception('Nessun dato disponibile dalla stazione');
        }
      } else if (response.statusCode == 401) {
        debugPrint('❌ Token MeteoNetwork non valido o scaduto');
        _useMockData();
      } else {
        debugPrint('❌ Errore API MeteoNetwork: ${response.statusCode}');
        _useMockData();
      }
    } catch (e) {
      debugPrint('❌ Errore nel recupero meteo: $e');
      _useMockData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _generateDescription() {
    // Descrizione automatica basata sui parametri meteo
    if (_rainRate > 0) {
      if (_rainRate > 10) return 'Pioggia intensa';
      if (_rainRate > 2) return 'Pioggia moderata';
      return 'Pioggia leggera';
    }
    
    if (_humidity > 85) return 'Umido';
    if (_humidity < 30) return 'Secco';
    
    final hour = DateTime.now().hour;
    if (_windSpeed > 20) {
      return 'Ventoso';
    } else if (hour >= 6 && hour < 20) {
      return 'Sereno';
    } else {
      return 'Notte serena';
    }
  }

  String _getWeatherIcon() {
    // Icona basata su pioggia e orario
    if (_rainRate > 0) {
      if (_rainRate > 10) return '⛈️';
      return '🌧️';
    }
    
    final hour = DateTime.now().hour;
    if (_windSpeed > 20) return '💨';
    
    if (hour >= 6 && hour < 8) return '🌅';
    if (hour >= 8 && hour < 18) return '☀️';
    if (hour >= 18 && hour < 20) return '🌇';
    return '🌙';
  }

  void _useMockData() {
    // Dati realistici di esempio (simili a quelli della stazione)
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      _temperature = '15.2';
      _description = 'Sereno';
      _icon = '☀️';
      _humidity = 75;
      _windSpeed = 3.5;
    } else if (hour >= 12 && hour < 18) {
      _temperature = '18.2';
      _description = 'Sereno';
      _icon = '☀️';
      _humidity = 81;
      _windSpeed = 2.0;
    } else {
      _temperature = '14.5';
      _description = 'Notte serena';
      _icon = '🌙';
      _humidity = 85;
      _windSpeed = 1.5;
    }
    _pressure = 1020.1;
    _rainRate = 0.0;
    _dewPoint = 14.9;
  }

  Future<void> getWeatherForCassino() async {
    await fetchWeather();
  }
}
