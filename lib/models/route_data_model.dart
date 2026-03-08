import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteStepModel {
  final String instruction;
  final double distance;
  final double duration;
  final LatLng location;

  const RouteStepModel({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.location,
  });
}

class RouteDataModel {
  final List<LatLng> polylinePoints;
  final List<RouteStepModel> steps;
  final double distanceMeters;
  final double durationSeconds;

  const RouteDataModel({
    required this.polylinePoints,
    required this.steps,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}
