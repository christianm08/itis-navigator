import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Geographic calculation utilities
class GeoUtils {
  GeoUtils._();

  /// Earth's radius in meters
  static const double _earthRadius = 6371000.0;

  /// Calculate distance between two points using Haversine formula
  /// Returns distance in meters
  static double haversineDistance(LatLng a, LatLng b) {
    final lat1 = a.latitude * math.pi / 180;
    final lat2 = b.latitude * math.pi / 180;
    final dlat = (b.latitude - a.latitude) * math.pi / 180;
    final dlng = (b.longitude - a.longitude) * math.pi / 180;

    final sinLat = math.sin(dlat / 2);
    final sinLng = math.sin(dlng / 2);
    final h = sinLat * sinLat +
        math.cos(lat1) * math.cos(lat2) * sinLng * sinLng;

    return 2 * _earthRadius * math.asin(math.sqrt(h));
  }

  /// Calculate total length of a polyline
  /// Returns length in meters
  static double polylineLength(List<LatLng> points) {
    if (points.length < 2) return 0.0;

    double total = 0.0;
    for (int i = 1; i < points.length; i++) {
      total += haversineDistance(points[i - 1], points[i]);
    }
    return total;
  }

  /// Find the closest point on a polyline to a given position
  /// Returns (index, distance) of the closest point
  static ({int index, double distance}) snapToPolyline(
    LatLng position,
    List<LatLng> polyline,
  ) {
    if (polyline.isEmpty) return (index: 0, distance: 0.0);

    int bestIndex = 0;
    double bestDist = double.infinity;

    for (int i = 0; i < polyline.length; i++) {
      final d = haversineDistance(position, polyline[i]);
      if (d < bestDist) {
        bestDist = d;
        bestIndex = i;
      }
    }

    return (index: bestIndex, distance: bestDist);
  }

  /// Find the closest point on a polyline within a window around a snap index
  /// Returns (index, distance) of the closest point
  static ({int index, double distance}) snapToPolylineWindowed(
    LatLng position,
    List<LatLng> polyline,
    int currentSnapIndex,
    int windowSize,
  ) {
    if (polyline.isEmpty) return (index: 0, distance: 0.0);

    final winStart = (currentSnapIndex - windowSize).clamp(0, polyline.length - 1);
    final winEnd = (currentSnapIndex + windowSize).clamp(0, polyline.length - 1);

    int bestIndex = currentSnapIndex;
    double bestDist = double.infinity;

    for (int i = winStart; i <= winEnd; i++) {
      final d = haversineDistance(position, polyline[i]);
      if (d < bestDist) {
        bestDist = d;
        bestIndex = i;
      }
    }

    return (index: bestIndex, distance: bestDist);
  }

  /// Format distance for display
  /// Returns formatted string (e.g., "1.5 km" or "250 m")
  static String formatDistance(double distanceMeters) {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '${distanceMeters.round()} m';
  }

  /// Format duration for display
  /// Returns formatted string (e.g., "1h 30m" or "45 min")
  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes} min';
    }
    return '${duration.inSeconds} sec';
  }

  /// Calculate estimated time of arrival given current speed
  /// Returns duration in seconds
  static Duration calculateETA(double remainingDistanceMeters, double speedMetersPerSecond) {
    if (speedMetersPerSecond <= 0) return Duration.zero;
    return Duration(seconds: (remainingDistanceMeters / speedMetersPerSecond).round());
  }

  /// Calculate progress as a fraction (0.0 to 1.0)
  static double calculateProgress(double traveledDistance, double totalDistance) {
    if (totalDistance <= 0) return 0.0;
    return ((totalDistance - traveledDistance) / totalDistance).clamp(0.0, 1.0);
  }
}
