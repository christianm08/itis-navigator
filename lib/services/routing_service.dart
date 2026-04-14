import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/route_data_model.dart';
import '../constants/route_constants.dart';
import '../constants/app_strings.dart';
import '../utils/geo_utils.dart';

/// Percorso pedonale fisso Stazione Cassino → ITIS.
/// Fonte: BRouter-1.7.0, profilo pedonale, semplificato (102 pt).
/// Distanza totale: 2751m  Durata: ~1965s (~32 min)
const _kRoutePolyline = RouteConstants.kRoutePolyline;

/// Soglia oltre la quale si considera l'utente fuori percorso (metri).
const double _kOffRouteThresholdM = AppStrings.offRouteThreshold;

class RoutingService {
  /// Restituisce il percorso da seguire a partire dalla posizione [start].
  ///
  /// Se [start] è SUL percorso (≤40 m): restituisce la polilinea
  /// tagliata dal punto di snap in poi.
  ///
  /// Se [start] è FUORI percorso (>40 m): chiama OSRM per ottenere un
  /// percorso pedonale reale (su strade) dalla posizione attuale al punto
  /// di snap, poi concatena il resto del percorso fisso BRouter.
  Future<RouteDataModel> fetchWalkingRoute({
    required LatLng start,
    required LatLng end,
    List<LatLng>? waypoints,
  }) async {
    final oriented = _orientToward(end);
    final snap = _snapToRoute(start, oriented);

    List<LatLng> polyline;
    List<RouteStepModel>? connectorSteps;
    double connectorDistanceM = 0;
    double connectorDurationS = 0;

    if (snap.distanceMeters <= _kOffRouteThresholdM) {
      final trimmed = oriented.sublist(snap.index);
      polyline = trimmed.length >= 2 ? trimmed : oriented;
    } else {
      final snapPoint = oriented[snap.index];
      final rest = oriented.sublist(snap.index);
      final connector = await _fetchOsrmWalkingRoute(start, snapPoint);
      if (connector != null) {
        polyline = [...connector.polylinePoints, ...rest];
        connectorSteps = connector.steps;
        connectorDistanceM = connector.distanceMeters;
        connectorDurationS = connector.durationSeconds;
      } else {
        polyline = [start, snapPoint, ...rest];
      }
    }

    final restLength = GeoUtils.polylineLength(oriented.sublist(snap.index));
    final distanceM = connectorDistanceM > 0
        ? connectorDistanceM + restLength
        : GeoUtils.polylineLength(polyline);
    final durationS = connectorDurationS > 0
        ? connectorDurationS + restLength / AppStrings.walkingSpeed
        : distanceM / AppStrings.walkingSpeed;

    final List<RouteStepModel> steps;
    if (connectorSteps != null && connectorSteps.isNotEmpty) {
      steps = [
        ...connectorSteps,
        RouteStepModel(
          instruction: AppStrings.mainRouteContinue,
          location: oriented[snap.index],
          distance: restLength,
          duration: restLength / AppStrings.walkingSpeed,
        ),
        RouteStepModel(
          instruction: AppStrings.arriveDestination,
          location: polyline.last,
          distance: 0,
          duration: 0,
        ),
      ];
    } else {
      steps = _buildSteps(polyline, distanceM, durationS);
    }

    return RouteDataModel(
      polylinePoints: polyline,
      steps: steps,
      distanceMeters: distanceM,
      durationSeconds: durationS,
    );
  }

  // ---------------------------------------------------------------------------
  // OSRM – Percorso pedonale reale via API pubblica
  // ---------------------------------------------------------------------------

  Future<_OsrmRouteResult?> _fetchOsrmWalkingRoute(
      LatLng from, LatLng to) async {
    final coords =
        '${from.longitude},${from.latitude};${to.longitude},${to.latitude}';
    final uri = Uri.parse(
        'https://routing.openstreetmap.de/routed-foot/route/v1/walking/$coords'
        '?overview=full&geometries=geojson&steps=true');

    try {
      final response = await http.get(uri).timeout(
        const Duration(seconds: AppStrings.osrmTimeoutSeconds),
        onTimeout: () => http.Response('timeout', 408),
      );

      if (response.statusCode != 200) {
        if (kDebugMode) debugPrint('⚠️ OSRM HTTP ${response.statusCode}');
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['code'] != 'Ok' || (json['routes'] as List).isEmpty) {
        if (kDebugMode) debugPrint('⚠️ OSRM nessun percorso trovato');
        return null;
      }

      final route = (json['routes'] as List).first as Map<String, dynamic>;

      final geometry = route['geometry'] as Map<String, dynamic>;
      final coordsList = geometry['coordinates'] as List;
      final polylinePoints = coordsList.map<LatLng>((c) {
        final coord = c as List;
        return LatLng(
            (coord[1] as num).toDouble(), (coord[0] as num).toDouble());
      }).toList();

      final distanceM = (route['distance'] as num).toDouble();
      final durationS = (route['duration'] as num).toDouble();

      final legs = route['legs'] as List;
      final osrmSteps = <RouteStepModel>[];
      if (legs.isNotEmpty) {
        final stepsJson =
            (legs.first as Map<String, dynamic>)['steps'] as List;
        for (final s in stepsJson) {
          final step = s as Map<String, dynamic>;
          final maneuver = step['maneuver'] as Map<String, dynamic>;
          final loc = maneuver['location'] as List;
          final instruction = _osrmManeuverToItalian(
            maneuver['type'] as String? ?? '',
            maneuver['modifier'] as String?,
            step['name'] as String? ?? '',
          );
          osrmSteps.add(RouteStepModel(
            instruction: instruction,
            location: LatLng(
                (loc[1] as num).toDouble(), (loc[0] as num).toDouble()),
            distance: (step['distance'] as num).toDouble(),
            duration: (step['duration'] as num).toDouble(),
          ));
        }
      }

      if (kDebugMode) {
        debugPrint('✅ OSRM connettore: ${distanceM.round()}m, '
            '${osrmSteps.length} step, ${polylinePoints.length} punti');
      }

      return _OsrmRouteResult(
        polylinePoints: polylinePoints,
        steps: osrmSteps,
        distanceMeters: distanceM,
        durationSeconds: durationS,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ OSRM errore: $e');
      return null;
    }
  }

  String _osrmManeuverToItalian(
      String type, String? modifier, String streetName) {
    final street = streetName.isNotEmpty ? ' su $streetName' : '';
    switch (type) {
      case 'depart':
        return 'Parti$street';
      case 'arrive':
        return 'Sei arrivato$street';
      case 'turn':
        switch (modifier) {
          case 'left':
          case 'sharp left':
          case 'slight left':
            return 'Gira a sinistra$street';
          case 'right':
          case 'sharp right':
          case 'slight right':
            return 'Gira a destra$street';
          case 'uturn':
            return 'Fai inversione$street';
          default:
            return 'Gira$street';
        }
      case 'new name':
      case 'continue':
        return 'Continua$street';
      case 'merge':
        return 'Immettiti$street';
      case 'fork':
        if (modifier?.contains('left') ?? false) return 'Tieni la sinistra$street';
        return 'Tieni la destra$street';
      case 'roundabout':
      case 'rotary':
        return 'Entra nella rotonda$street';
      case 'exit roundabout':
      case 'exit rotary':
        return 'Esci dalla rotonda$street';
      case 'end of road':
        if (modifier?.contains('left') ?? false) {
          return 'A fine strada, gira a sinistra$street';
        }
        return 'A fine strada, gira a destra$street';
      default:
        return 'Prosegui$street';
    }
  }

  // ---------------------------------------------------------------------------
  // Utilità geometriche
  // ---------------------------------------------------------------------------

  List<LatLng> _orientToward(LatLng destination) {
    final dFirst = GeoUtils.haversineDistance(_kRoutePolyline.first, destination);
    final dLast  = GeoUtils.haversineDistance(_kRoutePolyline.last,  destination);
    return dLast <= dFirst
        ? List<LatLng>.from(_kRoutePolyline)
        : _kRoutePolyline.reversed.toList();
  }

  _SnapResult _snapToRoute(LatLng pos, List<LatLng> polyline) {
    final result = GeoUtils.snapToPolyline(pos, polyline);
    return _SnapResult(result.index, result.distance);
  }

  List<RouteStepModel> _buildSteps(
      List<LatLng> polyline, double distanceM, double durationS) {
    return [
      RouteStepModel(
        instruction: AppStrings.startRoute,
        location: polyline.first,
        distance: distanceM,
        duration: durationS,
      ),
      RouteStepModel(
        instruction: AppStrings.arriveDestination,
        location: polyline.last,
        distance: 0,
        duration: 0,
      ),
    ];
  }
}

// ---------------------------------------------------------------------------
// Classi di supporto private
// ---------------------------------------------------------------------------

class _OsrmRouteResult {
  final List<LatLng> polylinePoints;
  final List<RouteStepModel> steps;
  final double distanceMeters;
  final double durationSeconds;

  const _OsrmRouteResult({
    required this.polylinePoints,
    required this.steps,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}

class _SnapResult {
  final int index;
  final double distanceMeters;
  const _SnapResult(this.index, this.distanceMeters);
}
