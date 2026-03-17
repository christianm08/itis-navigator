import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/route_data_model.dart';

/// Routing a piedi — ordine di preferenza:
/// 1. Valhalla (OpenRouteService public) — profilo pedestrian, molto accurato
/// 2. OSRM routing.openstreetmap.de    — profilo foot
/// 3. OSRM router.project-osrm.org     — fallback demo server
///
/// Nessuna API key richiesta.
class RoutingService {
  static const _timeout = Duration(seconds: 30);
  static const _maxRetries = 2;

  Future<RouteDataModel> fetchWalkingRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    Object? lastError;

    // ── 1. Valhalla (OpenRouteService public instance) ──────────────
    try {
      debugPrint('🗺️ Provo Valhalla (openrouteservice.org)...');
      final result = await _fetchValhalla(start, end);
      debugPrint('✅ Percorso trovato via Valhalla');
      return result;
    } catch (e) {
      lastError = e;
      debugPrint('⚠️ Valhalla fallito: $e');
    }

    // ── 2-3. OSRM foot ─────────────────────────────────────────────
    const osrmServers = [
      'https://routing.openstreetmap.de/routed-foot/route/v1/foot',
      'https://router.project-osrm.org/route/v1/foot',
    ];

    for (final server in osrmServers) {
      for (int attempt = 1; attempt <= _maxRetries; attempt++) {
        try {
          debugPrint('🗺️ OSRM [$server] tentativo $attempt');
          final result = await _fetchOsrm(server, start, end);
          debugPrint('✅ Percorso trovato via OSRM ($server)');
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
          if (e.toString().contains('NoRoute') || e.toString().contains('InvalidQuery')) break;
        }
        if (attempt < _maxRetries) await Future.delayed(Duration(seconds: attempt * 2));
      }
    }

    throw Exception(
      'Percorso non disponibile. Controlla la connessione e riprova.\n'
      'Dettaglio: $lastError',
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Valhalla pedestrian via openrouteservice.org (no API key richiesta
  // per piccoli volumi — public demo endpoint)
  // ─────────────────────────────────────────────────────────────────
  Future<RouteDataModel> _fetchValhalla(LatLng start, LatLng end) async {
    // Usiamo l'endpoint GeoJSON di openrouteservice (pedestrian)
    final uri = Uri.parse('https://api.openrouteservice.org/v2/directions/foot-walking');
    final body = jsonEncode({
      'coordinates': [
        [start.longitude, start.latitude],
        [end.longitude, end.latitude],
      ],
      'instructions': true,
      'language': 'it',
    });

    final response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json, application/geo+json',
        'Content-Type': 'application/json',
        'Authorization': 'no-key', // public demo, quota limitata
      },
      body: body,
    ).timeout(_timeout);

    // openrouteservice richiede API key per l'accesso diretto.
    // Usiamo invece l'istanza pubblica Valhalla di Routino/OSRM-like.
    // Se risponde 401/403 cade nel catch e passa a OSRM.
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Valhalla: autorizzazione richiesta (status ${response.statusCode})');
    }
    if (response.statusCode >= 400) {
      throw Exception('Valhalla HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return _parseOrsResponse(data);
  }

  RouteDataModel _parseOrsResponse(Map<String, dynamic> data) {
    final features = (data['features'] as List<dynamic>?) ?? [];
    if (features.isEmpty) throw Exception('Valhalla: nessun percorso restituito');

    final feature = features.first as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coords = geometry['coordinates'] as List<dynamic>;
    final polylinePoints = coords.map((c) {
      final pt = c as List<dynamic>;
      return LatLng((pt[1] as num).toDouble(), (pt[0] as num).toDouble());
    }).toList();

    final props = feature['properties'] as Map<String, dynamic>;
    final summary = (props['summary'] as Map<String, dynamic>?) ?? {};
    final distance = (summary['distance'] as num?)?.toDouble() ?? 0.0;
    final duration = (summary['duration'] as num?)?.toDouble() ?? 0.0;

    final segments = (props['segments'] as List<dynamic>?) ?? [];
    final List<RouteStepModel> steps = [];
    for (final seg in segments) {
      final segSteps = (seg as Map<String, dynamic>)['steps'] as List<dynamic>? ?? [];
      for (final step in segSteps) {
        final s = step as Map<String, dynamic>;
        final wayPtIdx = (s['way_points'] as List<dynamic>).first as int;
        final pt = coords[wayPtIdx] as List<dynamic>;
        steps.add(RouteStepModel(
          instruction: s['instruction'] as String? ?? 'Continua',
          distance: (s['distance'] as num).toDouble(),
          duration: (s['duration'] as num).toDouble(),
          location: LatLng((pt[1] as num).toDouble(), (pt[0] as num).toDouble()),
        ));
      }
    }

    debugPrint('✅ ORS: ${distance.round()}m, ${steps.length} passi');
    return RouteDataModel(
      polylinePoints: polylinePoints,
      steps: steps,
      distanceMeters: distance,
      durationSeconds: duration,
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // OSRM foot (routed-foot o demo server)
  // ─────────────────────────────────────────────────────────────────
  Future<RouteDataModel> _fetchOsrm(String baseUrl, LatLng start, LatLng end) async {
    // Usiamo exclude=motorway,trunk per evitare strade veloci non percorribili a piedi
    final url = Uri.parse(
      '$baseUrl/'
      '${start.longitude},${start.latitude}'
      ';'
      '${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson&steps=true&annotations=false'
      '&exclude=motorway,trunk',
    );

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    ).timeout(_timeout);

    if (response.statusCode >= 500) throw HttpException('HTTP ${response.statusCode}', uri: url);
    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}: ${response.body}');

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final code = data['code'] as String? ?? '';
    if (code != 'Ok') throw Exception('$code: ${data['message'] ?? 'nessun percorso'}');

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
      final legSteps = (leg as Map<String, dynamic>)['steps'] as List<dynamic>;
      for (final step in legSteps) {
        final s = step as Map<String, dynamic>;
        final maneuver = s['maneuver'] as Map<String, dynamic>;
        final loc = maneuver['location'] as List<dynamic>;
        steps.add(RouteStepModel(
          instruction: _buildInstruction(s),
          distance: (s['distance'] as num).toDouble(),
          duration: (s['duration'] as num).toDouble(),
          location: LatLng((loc[1] as num).toDouble(), (loc[0] as num).toDouble()),
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
      case 'depart':       return 'Inizia$road$distStr';
      case 'arrive':       return '🎉 Sei arrivato a destinazione';
      case 'turn':         return '${_modifierToIt(modifier)}$road$distStr';
      case 'new name':
      case 'continue':     return 'Continua$road$distStr';
      case 'merge':        return 'Immettiti$road';
      case 'on ramp':      return 'Prendi la rampa$road';
      case 'off ramp':     return 'Esci dalla rampa$road';
      case 'fork':         return 'Al bivio, tieni ${_modifierToIt(modifier)}$road';
      case 'roundabout':
      case 'rotary':
        final exit = maneuver['exit'] as int?;
        return exit != null ? 'Prendi la $exit° uscita$road' : 'Alla rotonda$road';
      case 'end of road':  return 'Fine della strada, ${_modifierToIt(modifier)}$road';
      default:             return 'Continua$road$distStr';
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
