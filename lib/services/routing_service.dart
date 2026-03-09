import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../config/local_api_keys.dart';
import '../models/route_data_model.dart';

class RoutingService {
  static const String _baseUrl = 'https://api.openrouteservice.org/v2/directions/foot-walking';

  Future<RouteDataModel> fetchWalkingRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    final key = LocalApiKeys.openRouteServiceApiKey;
    if (key.isEmpty || key == 'TEMP_REPLACE_ME') {
      throw Exception('API key OpenRouteService mancante');
    }

    final uri = Uri.parse(_baseUrl);
    final response = await http.post(
      uri,
      headers: {
        'Authorization': key,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'coordinates': [
          [start.longitude, start.latitude],
          [end.longitude, end.latitude],
        ],
        'instructions': true,
        'language': 'it',
        'units': 'm',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Errore routing ORS: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final features = data['features'] as List<dynamic>;
    if (features.isEmpty) {
      throw Exception('Nessun percorso trovato');
    }

    final feature = features.first as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;
    final properties = feature['properties'] as Map<String, dynamic>;
    final summary = properties['summary'] as Map<String, dynamic>;
    final segments = properties['segments'] as List<dynamic>;

    final polylinePoints = coordinates.map((coord) {
      final point = coord as List<dynamic>;
      return LatLng((point[1] as num).toDouble(), (point[0] as num).toDouble());
    }).toList();

    final List<RouteStepModel> steps = [];
    for (final segment in segments) {
      final segmentMap = segment as Map<String, dynamic>;
      final segmentSteps = segmentMap['steps'] as List<dynamic>;
      for (final step in segmentSteps) {
        final stepMap = step as Map<String, dynamic>;
        final waypointIndexes = stepMap['way_points'] as List<dynamic>;
        final waypointIndex = (waypointIndexes.first as num).toInt();
        final location = polylinePoints[waypointIndex.clamp(0, polylinePoints.length - 1)];
        steps.add(
          RouteStepModel(
            instruction: (stepMap['instruction'] ?? 'Continua sul percorso').toString(),
            distance: (stepMap['distance'] as num?)?.toDouble() ?? 0,
            duration: (stepMap['duration'] as num?)?.toDouble() ?? 0,
            location: location,
          ),
        );
      }
    }

    return RouteDataModel(
      polylinePoints: polylinePoints,
      steps: steps,
      distanceMeters: (summary['distance'] as num).toDouble(),
      durationSeconds: (summary['duration'] as num).toDouble(),
    );
  }
}
