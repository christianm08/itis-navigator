import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/route_data_model.dart';

/// Routing a piedi tramite OSRM (OpenStreetMap) — profilo foot.
///
/// Server provati in ordine:
///   1. routing.openstreetmap.de  (stable, profilo foot dedicato)
///   2. router.project-osrm.org   (demo server, fallback)
///
/// Parametri usati:
///   - exclude=motorway,trunk  → evita strade veloci non percorribili a piedi
///   - overview=full           → geometria completa (non semplificata)
///   - geometries=geojson      → coordinate lat/lng dirette
///   - steps=true              → istruzioni turn-by-turn
class RoutingService {
  static const _timeout = Duration(seconds: 20);
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
          final result = await _fetch(server, start, end);
          debugPrint('✅ Percorso trovato via $server');
          return result;
        } on SocketException catch (e) {
          lastError = e;
          debugPrint('⚠️ SocketException $server tentativo $attempt: $e');
        } on HttpException catch (e) {
          lastError = e;
          debugPrint('⚠️ HttpException $server tentativo $attempt: $e');
        } on TimeoutException catch (e) {
          lastError = e;
          debugPrint('⚠️ Timeout $server tentativo $attempt: $e');
        } catch (e) {
          lastError = e;
          debugPrint('⚠️ Errore $server tentativo $attempt: $e');
          // Errori logici OSRM (NoRoute, InvalidQuery) → non ritentare stesso server
          final msg = e.toString();
          if (msg.contains('NoRoute') || msg.contains('InvalidQuery')) break;
        }
        if (attempt < _maxRetries) {
          await Future.delayed(Duration(seconds: attempt));
        }
      }
    }

    final detail = lastError.toString();
    final short = detail.length > 100 ? '${detail.substring(0, 100)}…' : detail;
    throw Exception('Percorso non disponibile. Controlla la connessione.\n$short');
  }

  Future<RouteDataModel> _fetch(
    String baseUrl,
    LatLng start,
    LatLng end,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/'
      '${start.longitude},${start.latitude}'
      ';'
      '${end.longitude},${end.latitude}'
      '?overview=full'
      '&geometries=geojson'
      '&steps=true'
      '&annotations=false'
      '&exclude=motorway%2Ctrunk',  // esclude autostrade e strade di scorrimento
    );

    debugPrint('🔗 URL: $uri');

    final response = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(_timeout);

    if (response.statusCode >= 500) {
      throw HttpException('HTTP ${response.statusCode}', uri: uri);
    }
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final code = data['code'] as String? ?? '';
    if (code != 'Ok') {
      throw Exception('OSRM $code: ${data['message'] ?? 'nessun percorso'}');
    }

    final routes = data['routes'] as List<dynamic>;
    if (routes.isEmpty) throw Exception('Nessun percorso restituito dal server');

    final route = routes.first as Map<String, dynamic>;
    final legs = route['legs'] as List<dynamic>;

    // Polyline dal geometry GeoJSON
    final geometry = route['geometry'] as Map<String, dynamic>;
    final coords = geometry['coordinates'] as List<dynamic>;
    final polylinePoints = coords.map((c) {
      final pt = c as List<dynamic>;
      return LatLng((pt[1] as num).toDouble(), (pt[0] as num).toDouble());
    }).toList();

    // Steps (istruzioni turn-by-turn)
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

    final distM = (route['distance'] as num).toDouble();
    final durS  = (route['duration'] as num).toDouble();
    debugPrint('✅ OSRM: ${distM.round()}m, ${durS.round()}s, ${steps.length} step');

    return RouteDataModel(
      polylinePoints: polylinePoints,
      steps: steps,
      distanceMeters: distM,
      durationSeconds: durS,
    );
  }

  // ── Costruzione istruzione italiana ──────────

  String _buildInstruction(Map<String, dynamic> step) {
    final maneuver = step['maneuver'] as Map<String, dynamic>;
    final type     = maneuver['type']     as String? ?? '';
    final modifier = maneuver['modifier'] as String? ?? '';
    final name     = (step['name'] as String?)?.trim() ?? '';
    final distance = (step['distance'] as num).round();

    final road    = name.isNotEmpty ? ' su $name' : '';
    final distStr = distance > 0 ? ' per ${distance}m' : '';

    switch (type) {
      case 'depart':
        return 'Parti$road$distStr';
      case 'arrive':
        return '🎉 Sei arrivato a destinazione';
      case 'turn':
        return '${_mod(modifier)}$road$distStr';
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
        return 'Al bivio tieni ${_mod(modifier)}$road';
      case 'roundabout':
      case 'rotary':
        final exit = maneuver['exit'] as int?;
        return exit != null
            ? 'Alla rotonda prendi la $exit° uscita$road'
            : 'Alla rotonda$road';
      case 'end of road':
        return 'Fine della strada, ${_mod(modifier)}$road';
      default:
        return 'Continua$road$distStr';
    }
  }

  String _mod(String m) {
    switch (m) {
      case 'left':         return 'Svolta a sinistra';
      case 'right':        return 'Svolta a destra';
      case 'sharp left':   return 'Svolta decisa a sinistra';
      case 'sharp right':  return 'Svolta decisa a destra';
      case 'slight left':  return 'Tieni la sinistra';
      case 'slight right': return 'Tieni la destra';
      case 'straight':     return 'Vai dritto';
      case 'uturn':        return 'Inversione di marcia';
      default:             return 'Continua';
    }
  }
}
