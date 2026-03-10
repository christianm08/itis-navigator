import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/route_data_model.dart';

/// Routing a piedi via OSRM (OpenStreetMap)
/// Primary  : routing.openstreetmap.de  (più stabile)
/// Fallback : router.project-osrm.org   (demo server)
/// Nessuna API key richiesta.
class RoutingService {
  static const _timeout = Duration(seconds: 30);
  static const _maxRetries = 3;

  static const _servers = [
    'https://routing.openstreetmap.de/routed-foot/route/v1/foot',
    'https://router.project-osrm.org/route/v1/foot',
  ];

  Future<RouteDataModel> fetchWalkingRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    Object? lastError;

    for (final server in _servers) {
      for (int attempt = 1; attempt <= _maxRetries; attempt++) {
        try {
          debugPrint('🗺️ [$server] tentativo $attempt');
          final result = await _fetchFrom(server, start, end);
          debugPrint('✅ Percorso trovato via $server');
          return result;
        } on SocketException catch (e) {
          lastError = e;
          debugPrint('⚠️ SocketException $server (tentativo $attempt): $e');
        } on HttpException catch (e) {
          lastError = e;
          debugPrint('⚠️ HttpException $server (tentativo $attempt): $e');
        } catch (e) {
          lastError = e;
          debugPrint('⚠️ Errore $server (tentativo $attempt): $e');
          // Se il server risponde con errore logico (non 5xx), non ritentare
          if (e.toString().contains('NoRoute') ||
              e.toString().contains('InvalidQuery')) {
            break;
          }
        }
        if (attempt < _maxRetries) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
    }

    throw Exception(
      'Percorso non disponibile. Controlla la connessione e riprova.\n'
      'Dettaglio: $lastError',
    );
  }

  Future<RouteDataModel> _fetchFrom(
    String baseUrl,
    LatLng start,
    LatLng end,
  ) async {
    final url = Uri.parse(
      '$baseUrl/'
      '${start.longitude},${start.latitude}'
      ';'
      '${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson&steps=true&annotations=false',
    );

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    ).timeout(_timeout);

    if (response.statusCode >= 500) {
      throw HttpException('HTTP ${response.statusCode}', uri: url);
    }
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final code = data['code'] as String? ?? '';
    if (code != 'Ok') {
      throw Exception('$code: ${data['message'] ?? 'nessun percorso'}');
    }

    final routes = data['routes'] as List<dynamic>;
    if (routes.isEmpty) throw Exception('Nessun percorso restituito');

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
      final legSteps =
          (leg as Map<String, dynamic>)['steps'] as List<dynamic>;
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

    debugPrint('✅ OSRM: ${(route['distance'] as num).round()}m, '
        '${steps.length} passi');

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
