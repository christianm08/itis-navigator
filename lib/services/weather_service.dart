import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WeatherService extends ChangeNotifier {
  bool _isLoading = false;
  String _temperature = '--';
  String _description = 'Caricamento...';
  String _icon = '☀️';
  int _humidity = 0;
  double _windSpeed = 0.0;

  bool get isLoading => _isLoading;
  String get temperature => _temperature;
  String get description => _description;
  String get icon => _icon;
  int get humidity => _humidity;
  double get windSpeed => _windSpeed;

  Future<void> fetchWeather() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Coordinate di Cassino
      const lat = 41.4897;
      const lon = 13.8283;
      const apiKey = 'YOUR_API_KEY'; // Sostituisci con la tua API key di OpenWeatherMap
      
      // Se non hai una API key, usa dati mock
      if (apiKey == 'YOUR_API_KEY') {
        _useMockData();
        return;
      }

      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=it',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        _temperature = data['main']['temp'].toStringAsFixed(0);
        _description = _capitalizeFirst(data['weather'][0]['description']);
        _humidity = data['main']['humidity'];
        _windSpeed = (data['wind']['speed'] * 3.6); // Converti m/s in km/h
        _icon = _getWeatherIcon(data['weather'][0]['main']);
      } else {
        _useMockData();
      }
    } catch (e) {
      debugPrint('Errore nel recupero meteo: $e');
      _useMockData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _useMockData() {
    // Dati di esempio quando l'API non è disponibile
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      _temperature = '15';
      _description = 'Sereno';
      _icon = '☀️';
    } else if (hour >= 12 && hour < 18) {
      _temperature = '22';
      _description = 'Parzialmente nuvoloso';
      _icon = '⛅';
    } else {
      _temperature = '18';
      _description = 'Sereno';
      _icon = '🌙';
    }
    _humidity = 65;
    _windSpeed = 12.5;
  }

  String _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
      case 'drizzle':
        return '🌧️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
      case 'fog':
        return '🌫️';
      default:
        return '☀️';
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
