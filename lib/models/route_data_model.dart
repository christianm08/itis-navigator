import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Represents a single navigation step with instruction, distance, duration, and location.
class RouteStepModel {
  /// Turn-by-turn instruction text (e.g., "Gira a destra su Via Roma")
  final String instruction;
  
  /// Distance for this step in meters
  final double distance;
  
  /// Estimated duration for this step in seconds
  final double duration;
  
  /// Geographic location of the step
  final LatLng location;

  const RouteStepModel({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.location,
  });

  /// Create a copy with modified fields
  RouteStepModel copyWith({
    String? instruction,
    double? distance,
    double? duration,
    LatLng? location,
  }) {
    return RouteStepModel(
      instruction: instruction ?? this.instruction,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      location: location ?? this.location,
    );
  }

  @override
  String toString() => 'RouteStepModel(instruction: $instruction, '
      'distance: ${distance.toStringAsFixed(0)}m, '
      'duration: ${duration.toStringAsFixed(0)}s)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteStepModel &&
          runtimeType == other.runtimeType &&
          instruction == other.instruction &&
          distance == other.distance &&
          duration == other.duration &&
          location == other.location;

  @override
  int get hashCode =>
      instruction.hashCode ^
      distance.hashCode ^
      duration.hashCode ^
      location.hashCode;
}

/// Represents a complete route with polyline, steps, distance, and duration.
class RouteDataModel {
  /// All points forming the route polyline
  final List<LatLng> polylinePoints;
  
  /// Individual navigation steps
  final List<RouteStepModel> steps;
  
  /// Total distance in meters
  final double distanceMeters;
  
  /// Total estimated duration in seconds
  final double durationSeconds;

  const RouteDataModel({
    required this.polylinePoints,
    required this.steps,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  /// Create a copy with modified fields
  RouteDataModel copyWith({
    List<LatLng>? polylinePoints,
    List<RouteStepModel>? steps,
    double? distanceMeters,
    double? durationSeconds,
  }) {
    return RouteDataModel(
      polylinePoints: polylinePoints ?? this.polylinePoints,
      steps: steps ?? this.steps,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  /// Create an empty route
  factory RouteDataModel.empty() {
    return const RouteDataModel(
      polylinePoints: [],
      steps: [],
      distanceMeters: 0.0,
      durationSeconds: 0.0,
    );
  }

  /// Check if route is valid (has points and steps)
  bool get isValid => polylinePoints.isNotEmpty && distanceMeters > 0;

  @override
  String toString() => 'RouteDataModel(points: ${polylinePoints.length}, '
      'steps: ${steps.length}, '
      'distance: ${distanceMeters.toStringAsFixed(0)}m, '
      'duration: ${durationSeconds.toStringAsFixed(0)}s)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteDataModel &&
          runtimeType == other.runtimeType &&
          polylinePoints == other.polylinePoints &&
          steps == other.steps &&
          distanceMeters == other.distanceMeters &&
          durationSeconds == other.durationSeconds;

  @override
  int get hashCode =>
      polylinePoints.hashCode ^
      steps.hashCode ^
      distanceMeters.hashCode ^
      durationSeconds.hashCode;
}
