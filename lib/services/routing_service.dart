import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/route_data_model.dart';

/// Routing via OSRM Demo Server (https://project-osrm.org)
/// - Completamente gratuito, nessuna API key richiesta
/// - Basato su OpenStreetMap
/// - Profilo: foot (a piedi)
class RoutingService {
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1/foot';

  Future<RouteDataModel> fetchWalkingRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    // OSRM: lon,lat (ordine invertito rispetto a Google)
    final url = Uri.parse(
      '$_baseUrl/'
      '${start.longitude},${start.latitude}'
      ';'
      '${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson&steps=true&annotations=false',
    );

    debugPrint('🗺️ OSRM routing: $url');

    final response =
        await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
          'Errore OSRM: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['code'] != 'Ok') {
      throw Exception('OSRM: ${data['code']} - ${data['message'] ?? 'percorso non trovato'}');
    }

    final routes = data['routes'] as List<dynamic>;
    if (routes.isEmpty) throw Exception('Nessun percorso trovato');

    final route = routes.first as Map<String, dynamic>;
    final legs = route['legs'] as List<dynamic>;

    // Polyline dal geometry GeoJSON
    final geometry = route['geometry'] as Map<String, dynamic>;
    final coords = geometry['coordinates'] as List<dynamic>;
    final polylinePoints = coords.map((c) {
      final pt = c as List<dynamic>;
      return LatLng((pt[1] as num).toDouble(), (pt[0] as num).toDouble());
    }).toList();

    // Steps da tutti i legs
    final List<RouteStepModel> steps = [];
    for (final leg in legs) {
      final legMap = leg as Map<String, dynamic>;
      final legSteps = legMap['steps'] as List<dynamic>;
      for (final step in legSteps) {
        final s = step as Map<String, dynamic>;
        final maneuver = s['maneuver'] as Map<String, dynamic>;
        final loc = maneuver['location'] as List<dynamic>;
        final stepLat = (loc[1] as num).toDouble();
        final stepLon = (loc[0] as num).toDouble();

        final instruction = _buildInstruction(s);

        steps.add(RouteStepModel(
          instruction: instruction,
          distance: (s['distance'] as num).toDouble(),
          duration: (s['duration'] as num).toDouble(),
          location: LatLng(stepLat, stepLon),
        ));
      }
    }

    final totalDistance = (route['distance'] as num).toDouble();
    final totalDuration = (route['duration'] as num).toDouble();

    debugPrint('✅ OSRM: ${totalDistance.round()}m, ${steps.length} passi');

    return RouteDataModel(
      polylinePoints: polylinePoints,
      steps: steps,
      distanceMeters: totalDistance,
      durationSeconds: totalDuration,
    );
  }

  /// Converte il maneuver OSRM in istruzione italiana leggibile
  String _buildInstruction(Map<String, dynamic> step) {
    final maneuver = step['maneuver'] as Map<String, dynamic>;
    final type = maneuver['type'] as String? ?? '';
    final modifier = maneuver['modifier'] as String? ?? '';
    final name = (step['name'] as String?)?.trim() ?? '';
    final distance = (step['distance'] as num).round();
    final road = name.isNotEmpty ? ' su $name' : '';
    final distStr = distance > 0 ? ' per ${distance}m' : '';

    switch (type) {
      case 'depart':
        return 'Inizia$road$distStr';
      case 'arrive':
        return '🎉 Sei arrivato a destinazione';
      case 'turn':
        return '${_modifierToIt(modifier)}$road$distStr';
      case 'new name':
        return 'Continua$road$distStr';
      case 'continue':
        return 'Continua${_modifierToIt(modifier, prefix: false)}$road$distStr';
      case 'merge':
        return 'Immettiti$road';
      case 'on ramp':
        return 'Prendi la rampa$road';
      case 'off ramp':
        return 'Esci dalla rampa$road';
      case 'fork':
        return 'Al bivio, tieni ${_modifierToIt(modifier, prefix: false)}$road';
      case 'roundabout':
      case 'rotary':
        final exit = maneuver['exit'] as int?;
        final exitStr = exit != null ? 'Prendi la $exit° uscita' : 'Alla rotonda';
        return '$exitStr$road';
      case 'end of road':
        return 'Fine della strada, ${_modifierToIt(modifier, prefix: false)}$road';
      default:
        return 'Continua$road$distStr';
    }
  }

  String _modifierToIt(String modifier, {bool prefix = true}) {
    final p = prefix ? '' : '';
    switch (modifier) {
      case 'left': return '${p}Svolta a sinistra';
      case 'right': return '${p}Svolta a destra';
      case 'sharp left': return '${p}Svolta decisa a sinistra';
      case 'sharp right': return '${p}Svolta decisa a destra';
      case 'slight left': return '${p}Tieni la sinistra';
      case 'slight right': return '${p}Tieni la destra';
      case 'straight': return '${p}Vai dritto';
      case 'uturn': return '${p}Fai inversione';
      default: return '${p}Continua';
    }
  }
}
