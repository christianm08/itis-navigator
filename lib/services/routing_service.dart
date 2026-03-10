import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/route_data_model.dart';

/// Routing via OSRM Demo Server (https://project-osrm.org)
/// - Completamente gratuito, nessuna API key richiesta
/// - Basato su OpenStreetMap, profilo: foot (a piedi)
class RoutingService {
  static const String _baseUrl =
      'https://router.project-osrm.org/route/v1/foot';

  Future<RouteDataModel> fetchWalkingRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/'
      '${start.longitude},${start.latitude}'
      ';'
      '${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson&steps=true&annotations=false',
    );

    debugPrint('🗺️ OSRM: $url');

    final response =
        await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Errore OSRM: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['code'] != 'Ok') {
      throw Exception(
          'OSRM: ${data['code']} - ${data['message'] ?? 'percorso non trovato'}');
    }

    final routes = data['routes'] as List<dynamic>;
    if (routes.isEmpty) throw Exception('Nessun percorso trovato');

    final route = routes.first as Map<String, dynamic>;
    final legs = route['legs'] as List<dynamic>;

    final geometry = route['geometry'] as Map<String, dynamic>;
    final coords = geometry['coordinates'] as List<dynamic>;
    final polylinePoints = coords.map((c) {
      final pt = c as List<dynamic>;
      return LatLng((pt[1] as num).toDouble(), (pt[0] as num).toDouble());
    }).toList();

    final List<RouteStepModel> steps = [];
    for (final leg in legs) {
      final legSteps = (leg as Map<String, dynamic>)['steps'] as List<dynamic>;
      for (final step in legSteps) {
        final s = step as Map<String, dynamic>;
        final maneuver = s['maneuver'] as Map<String, dynamic>;
        final loc = maneuver['location'] as List<dynamic>;
        steps.add(RouteStepModel(
          instruction: _buildInstruction(s),
          distance: (s['distance'] as num).toDouble(),
          duration: (s['duration'] as num).toDouble(),
          location: LatLng(
            (loc[1] as num).toDouble(),
            (loc[0] as num).toDouble(),
          ),
        ));
      }
    }

    debugPrint('✅ OSRM: ${(route['distance'] as num).round()}m, ${steps.length} passi');

    return RouteDataModel(
      polylinePoints: polylinePoints,
      steps: steps,
      distanceMeters: (route['distance'] as num).toDouble(),
      durationSeconds: (route['duration'] as num).toDouble(),
    );
  }

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
      case 'continue':
        return 'Continua$road$distStr';
      case 'merge':
        return 'Immettiti$road';
      case 'on ramp':
        return 'Prendi la rampa$road';
      case 'off ramp':
        return 'Esci dalla rampa$road';
      case 'fork':
        return 'Al bivio, tieni ${_modifierToIt(modifier)}$road';
      case 'roundabout':
      case 'rotary':
        final exit = maneuver['exit'] as int?;
        return exit != null
            ? 'Prendi la $exit° uscita$road'
            : 'Alla rotonda$road';
      case 'end of road':
        return 'Fine della strada, ${_modifierToIt(modifier)}$road';
      default:
        return 'Continua$road$distStr';
    }
  }

  String _modifierToIt(String modifier) {
    switch (modifier) {
      case 'left':         return 'Svolta a sinistra';
      case 'right':        return 'Svolta a destra';
      case 'sharp left':   return 'Svolta decisa a sinistra';
      case 'sharp right':  return 'Svolta decisa a destra';
      case 'slight left':  return 'Tieni la sinistra';
      case 'slight right': return 'Tieni la destra';
      case 'straight':     return 'Vai dritto';
      case 'uturn':        return 'Fai inversione';
      default:             return 'Continua';
    }
  }
}
