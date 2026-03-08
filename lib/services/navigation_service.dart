import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/landmark.dart';

class NavigationService extends ChangeNotifier {
  String _transportMode = 'walking';
  bool _isNavigating = false;
  bool _isOffRoute = false;
  bool _hasArrived = false;
  int _currentWaypointIndex = 0;
  List<Landmark> _waypoints = [];
  double _totalDistance = 0.0;
  double _remainingDistance = 0.0;
  double _distanceToNextWaypoint = 0.0;
  Duration _estimatedTimeRemaining = Duration.zero;
  String _currentInstruction = '';
  Position? _lastPosition;
  Timer? _navigationTimer;

  static const double waypointProximityThreshold = 18.0;
  static const double offRouteThreshold = 45.0;
  static const double arrivalThreshold = 20.0;
  static const double walkingSpeed = 1.4;
  static const double cyclingSpeed = 4.2;
  static const double drivingSpeed = 8.3;

  String get transportMode => _transportMode;
  bool get isNavigating => _isNavigating;
  bool get isOffRoute => _isOffRoute;
  bool get hasArrived => _hasArrived;
  int get currentWaypointIndex => _currentWaypointIndex;
  List<Landmark> get waypoints => _waypoints;
  double get totalDistance => _totalDistance;
  double get remainingDistance => _remainingDistance;
  double get distanceToNextWaypoint => _distanceToNextWaypoint;
  Duration get estimatedTimeRemaining => _estimatedTimeRemaining;
  String get currentInstruction => _currentInstruction;

  Landmark? get currentWaypoint =>
      _waypoints.isNotEmpty && _currentWaypointIndex < _waypoints.length
          ? _waypoints[_currentWaypointIndex]
          : null;

  Landmark? get destination => _waypoints.isNotEmpty ? _waypoints.last : null;

  double get progress {
    if (_waypoints.isEmpty || _totalDistance <= 0) return 0.0;
    final completed = (_totalDistance - _remainingDistance).clamp(0.0, _totalDistance);
    return completed / _totalDistance;
  }

  void setTransportMode(String mode) {
    _transportMode = mode;
    notifyListeners();
  }

  void initializeRoute(List<Landmark> waypoints) {
    _waypoints = List<Landmark>.from(waypoints);
    _currentWaypointIndex = 0;
    _isOffRoute = false;
    _hasArrived = false;
    _currentInstruction = '';
    _calculateTotalDistance();
    _remainingDistance = _totalDistance;
    notifyListeners();
  }

  void startNavigation() {
    if (_waypoints.isEmpty) return;
    _isNavigating = true;
    _hasArrived = false;
    _startNavigationTimer();
    _updateInstruction();
    notifyListeners();
  }

  void stopNavigation() {
    _isNavigating = false;
    _navigationTimer?.cancel();
    notifyListeners();
  }

  void _startNavigationTimer() {
    _navigationTimer?.cancel();
    _navigationTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      notifyListeners();
    });
  }

  void updatePosition(Position position) {
    if (!_isNavigating || _waypoints.isEmpty || _hasArrived) return;

    _lastPosition = position;
    _snapToBestWaypoint(position);

    final current = currentWaypoint;
    final dest = destination;
    if (current == null || dest == null) return;

    _distanceToNextWaypoint = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      current.latitude,
      current.longitude,
    );

    final distanceToDestination = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      dest.latitude,
      dest.longitude,
    );

    if (distanceToDestination <= arrivalThreshold) {
      _hasArrived = true;
      _isNavigating = false;
      _remainingDistance = 0;
      _estimatedTimeRemaining = Duration.zero;
      _currentInstruction = '🎉 Sei arrivato all\'ITIS E. Majorana!';
      _navigationTimer?.cancel();
      notifyListeners();
      return;
    }

    if (_distanceToNextWaypoint <= waypointProximityThreshold) {
      _advanceToNextWaypoint();
    }

    _isOffRoute = _computeOffRoute(position);

    if (_isOffRoute) {
      _recalculateFromNearestWaypoint(position);
      _currentInstruction = '⚠️ Percorso aggiornato: torna verso ${currentWaypoint?.name ?? 'il percorso'}';
    } else {
      _updateInstruction();
    }

    _calculateRemainingDistance(position);
    _calculateETA();
    notifyListeners();
  }

  void _snapToBestWaypoint(Position position) {
    if (_waypoints.isEmpty) return;

    int bestIndex = _currentWaypointIndex;
    double bestDistance = double.infinity;

    for (int i = _currentWaypointIndex; i < _waypoints.length; i++) {
      final waypoint = _waypoints[i];
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        waypoint.latitude,
        waypoint.longitude,
      );

      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }

    if (bestIndex > _currentWaypointIndex && bestDistance < 35) {
      _currentWaypointIndex = bestIndex;
    }
  }

  bool _computeOffRoute(Position position) {
    if (_currentWaypointIndex >= _waypoints.length) return false;

    final current = _waypoints[_currentWaypointIndex];
    final prev = _currentWaypointIndex > 0 ? _waypoints[_currentWaypointIndex - 1] : null;

    if (prev == null) {
      final directDistance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        current.latitude,
        current.longitude,
      );
      return directDistance > offRouteThreshold;
    }

    final distanceToPrev = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      prev.latitude,
      prev.longitude,
    );

    final distanceToCurrent = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      current.latitude,
      current.longitude,
    );

    final segmentDistance = Geolocator.distanceBetween(
      prev.latitude,
      prev.longitude,
      current.latitude,
      current.longitude,
    );

    final deviation = (distanceToPrev + distanceToCurrent) - segmentDistance;
    return deviation > offRouteThreshold;
  }

  void _recalculateFromNearestWaypoint(Position position) {
    int nearestIndex = _currentWaypointIndex;
    double nearestDistance = double.infinity;

    for (int i = 0; i < _waypoints.length; i++) {
      final waypoint = _waypoints[i];
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        waypoint.latitude,
        waypoint.longitude,
      );

      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestIndex = i;
      }
    }

    _currentWaypointIndex = nearestIndex;
  }

  void _advanceToNextWaypoint() {
    if (_currentWaypointIndex < _waypoints.length - 1) {
      _currentWaypointIndex++;
    }
    _updateInstruction();
  }

  void _updateInstruction() {
    final current = currentWaypoint;
    if (current == null) {
      _currentInstruction = 'Percorso non disponibile';
      return;
    }

    final isLast = _currentWaypointIndex >= _waypoints.length - 1;
    final prefix = _instructionPrefix(current.name);

    if (_currentWaypointIndex == 0) {
      _currentInstruction = '🚶 Parti ora e raggiungi ${current.name}';
    } else if (isLast) {
      _currentInstruction = '🎯 Ultimo tratto: $prefix ${current.name}';
    } else {
      _currentInstruction = '$prefix ${current.name}';
    }
  }

  String _instructionPrefix(String name) {
    if (name.contains('ATTRAVERSAMENTO')) return 'Attraversa verso';
    if (name.contains('ARRIVO')) return 'Raggiungi';
    if (name.contains('INIZIO')) return 'Procedi verso';
    return 'Vai verso';
  }

  void _calculateTotalDistance() {
    _totalDistance = 0.0;
    for (int i = 0; i < _waypoints.length - 1; i++) {
      _totalDistance += Geolocator.distanceBetween(
        _waypoints[i].latitude,
        _waypoints[i].longitude,
        _waypoints[i + 1].latitude,
        _waypoints[i + 1].longitude,
      );
    }
  }

  void _calculateRemainingDistance(Position position) {
    final current = currentWaypoint;
    if (current == null) {
      _remainingDistance = 0;
      return;
    }

    double total = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      current.latitude,
      current.longitude,
    );

    for (int i = _currentWaypointIndex; i < _waypoints.length - 1; i++) {
      total += Geolocator.distanceBetween(
        _waypoints[i].latitude,
        _waypoints[i].longitude,
        _waypoints[i + 1].latitude,
        _waypoints[i + 1].longitude,
      );
    }

    _remainingDistance = total;
    _distanceToNextWaypoint = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      current.latitude,
      current.longitude,
    );
  }

  void _calculateETA() {
    double speed = walkingSpeed;
    if (_transportMode == 'cycling') speed = cyclingSpeed;
    if (_transportMode == 'driving') speed = drivingSpeed;
    final seconds = (_remainingDistance / speed).round();
    _estimatedTimeRemaining = Duration(seconds: seconds.clamp(0, 86400));
  }

  String getFormattedETA() {
    if (_estimatedTimeRemaining.inHours > 0) {
      return '${_estimatedTimeRemaining.inHours}h ${_estimatedTimeRemaining.inMinutes % 60}m';
    }
    if (_estimatedTimeRemaining.inMinutes > 0) {
      return '${_estimatedTimeRemaining.inMinutes} min';
    }
    return '${_estimatedTimeRemaining.inSeconds} sec';
  }

  String getFormattedDistance() {
    final distance = _remainingDistance > 0 ? _remainingDistance : _distanceToNextWaypoint;
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
    return '${distance.round()} m';
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }
}
