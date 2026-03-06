import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  // Coordinate: Cassino (puoi cambiarle se vuoi)
  static const double _lat = 41.4901;
  static const double _lon = 13.8302;

  Future<Map<String, dynamic>> getWeatherForCassino() async {
    final url = Uri.parse(
      '$_baseUrl?latitude=$_lat&longitude=$_lon'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,pressure_msl'
      '&timezone=Europe/Rome',
    );

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Errore meteo: ${res.statusCode}');
    }

    final data = json.decode(res.body) as Map<String, dynamic>;
    final current = data['current'] as Map<String, dynamic>;

    return {
      'temperature': (current['temperature_2m'] as num).round(),
      'feelsLike': (current['apparent_temperature'] as num).round(),
      'humidity': current['relative_humidity_2m'],
      'windSpeed': (current['wind_speed_10m'] as num).round(),
      'pressure': (current['pressure_msl'] as num).round(),
      'description': _descFromCode(current['weather_code'] as int?),
    };
  }

  String _descFromCode(int? code) {
    if (code == null) return 'Sconosciuto';
    switch (code) {
      case 0:
        return 'Sereno';
      case 1:
      case 2:
      case 3:
        return 'Parzialmente nuvoloso';
      case 45:
      case 48:
        return 'Nebbia';
      case 51:
      case 53:
      case 55:
        return 'Pioviggine';
      case 61:
      case 63:
      case 65:
        return 'Pioggia';
      case 71:
      case 73:
      case 75:
        return 'Neve';
      case 80:
      case 81:
      case 82:
        return 'Rovesci di pioggia';
      case 95:
        return 'Temporale';
      default:
        return 'Variabile';
    }
  }
}
