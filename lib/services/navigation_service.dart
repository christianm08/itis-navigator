import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/landmark.dart';

class NavigationService extends ChangeNotifier {
  String _transportMode = 'walking';
  bool _isNavigating = false;
  int _currentWaypointIndex = 0;
  List<Landmark> _waypoints = [];
  double _totalDistance = 0.0;
  double _distanceToNextWaypoint = 0.0;
  Duration _estimatedTimeRemaining = Duration.zero;
  String _currentInstruction = '';
  Timer? _navigationTimer;

  // Costanti per la navigazione
  static const double waypointProximityThreshold = 15.0; // metri
  static const double offRouteThreshold = 50.0; // metri
  static const double walkingSpeed = 1.4; // m/s (circa 5 km/h)
  static const double cyclingSpeed = 4.2; // m/s (circa 15 km/h)
  static const double drivingSpeed = 8.3; // m/s (circa 30 km/h)

  String get transportMode => _transportMode;
  bool get isNavigating => _isNavigating;
  int get currentWaypointIndex => _currentWaypointIndex;
  List<Landmark> get waypoints => _waypoints;
  double get totalDistance => _totalDistance;
  double get distanceToNextWaypoint => _distanceToNextWaypoint;
  Duration get estimatedTimeRemaining => _estimatedTimeRemaining;
  String get currentInstruction => _currentInstruction;
  Landmark? get currentWaypoint => _waypoints.isNotEmpty && _currentWaypointIndex < _waypoints.length
      ? _waypoints[_currentWaypointIndex]
      : null;
  Landmark? get nextWaypoint => _waypoints.isNotEmpty && _currentWaypointIndex + 1 < _waypoints.length
      ? _waypoints[_currentWaypointIndex + 1]
      : null;

  double get progress {
    if (_waypoints.isEmpty) return 0.0;
    return _currentWaypointIndex / _waypoints.length;
  }

  void setTransportMode(String mode) {
    _transportMode = mode;
    notifyListeners();
  }

  void initializeRoute(List<Landmark> waypoints) {
    _waypoints = waypoints;
    _currentWaypointIndex = 0;
    _calculateTotalDistance();
    notifyListeners();
  }

  void startNavigation() {
    _isNavigating = true;
    _currentWaypointIndex = 0;
    _startNavigationTimer();
    _updateInstruction();
    notifyListeners();
  }

  void stopNavigation() {
    _isNavigating = false;
    _navigationTimer?.cancel();
    _currentWaypointIndex = 0;
    _currentInstruction = '';
    notifyListeners();
  }

  void _startNavigationTimer() {
    _navigationTimer?.cancel();
    _navigationTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      notifyListeners();
    });
  }

  void updatePosition(Position position) {
    if (!_isNavigating || _waypoints.isEmpty) return;

    final currentWaypoint = this.currentWaypoint;
    if (currentWaypoint == null) return;

    // Calcola distanza dal waypoint corrente
    _distanceToNextWaypoint = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      currentWaypoint.latitude,
      currentWaypoint.longitude,
    );

    // Verifica se siamo vicini al waypoint
    if (_distanceToNextWaypoint < waypointProximityThreshold) {
      _advanceToNextWaypoint();
    }

    // Verifica se siamo fuori percorso
    if (_isOffRoute(position)) {
      _currentInstruction = '⚠️ Fuori percorso! Ricalcolo in corso...';
    } else {
      _updateInstruction();
    }

    _calculateETA(position);
    notifyListeners();
  }

  bool _isOffRoute(Position position) {
    final currentWaypoint = this.currentWaypoint;
    if (currentWaypoint == null) return false;

    final distanceToRoute = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      currentWaypoint.latitude,
      currentWaypoint.longitude,
    );

    return distanceToRoute > offRouteThreshold;
  }

  void _advanceToNextWaypoint() {
    if (_currentWaypointIndex < _waypoints.length - 1) {
      _currentWaypointIndex++;
      _updateInstruction();
    } else {
      // Arrivo a destinazione
      _currentInstruction = '🎉 Sei arrivato a destinazione!';
      stopNavigation();
    }
  }

  void _updateInstruction() {
    final current = currentWaypoint;
    final next = nextWaypoint;

    if (current == null) {
      _currentInstruction = 'Nessun waypoint disponibile';
      return;
    }

    String direction = _getDirectionFromName(current.name);
    
    if (_currentWaypointIndex == 0) {
      _currentInstruction = '🚶 Inizia il percorso verso ${current.name}';
    } else if (next != null) {
      _currentInstruction = '$direction ${current.name}\nPoi continua verso ${next.name}';
    } else {
      _currentInstruction = '🎯 Ultimo tratto: $direction ${current.name}';
    }
  }

  String _getDirectionFromName(String name) {
    if (name.contains('ATTRAVERSAMENTO')) {
      return '🚦 Attraversa';
    } else if (name.contains('INIZIO')) {
      return '🚀 Parti da';
    } else if (name.contains('ARRIVO')) {
      return '🏁 Arrivo a';
    }
    return '➡️ Dirigiti verso';
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

  void _calculateETA(Position position) {
    double remainingDistance = _distanceToNextWaypoint;

    // Aggiungi la distanza dei waypoint rimanenti
    for (int i = _currentWaypointIndex; i < _waypoints.length - 1; i++) {
      remainingDistance += Geolocator.distanceBetween(
        _waypoints[i].latitude,
        _waypoints[i].longitude,
        _waypoints[i + 1].latitude,
        _waypoints[i + 1].longitude,
      );
    }

    // Calcola il tempo in base al mezzo di trasporto
    double speed = walkingSpeed;
    if (_transportMode == 'cycling') {
      speed = cyclingSpeed;
    } else if (_transportMode == 'driving') {
      speed = drivingSpeed;
    }

    final seconds = (remainingDistance / speed).round();
    _estimatedTimeRemaining = Duration(seconds: seconds);
  }

  String getFormattedETA() {
    if (_estimatedTimeRemaining.inHours > 0) {
      return '${_estimatedTimeRemaining.inHours}h ${_estimatedTimeRemaining.inMinutes % 60}min';
    } else if (_estimatedTimeRemaining.inMinutes > 0) {
      return '${_estimatedTimeRemaining.inMinutes} min';
    } else {
      return '${_estimatedTimeRemaining.inSeconds} sec';
    }
  }

  String getFormattedDistance() {
    if (_distanceToNextWaypoint >= 1000) {
      return '${(_distanceToNextWaypoint / 1000).toStringAsFixed(1)} km';
    } else {
      return '${_distanceToNextWaypoint.round()} m';
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }
}
