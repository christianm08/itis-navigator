import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/route_data_model.dart';
import '../screens/qr_scanner_screen.dart' show kQrPoints;
import 'routing_service.dart';

class NavigationService extends ChangeNotifier {
  final RoutingService _routingService = RoutingService();

  bool _isNavigating = false;
  bool _isOffRoute = false;
  bool _hasArrived = false;
  bool _isCalculatingRoute = false;
  int _currentStepIndex = 0;
  double _remainingDistance = 0.0;
  Duration _estimatedTimeRemaining = Duration.zero;
  String _currentInstruction = '';
  String? _error;
  RouteDataModel? _activeRoute;
  LatLng? _destination;
  String _destinationName = '';
  DateTime? _lastRerouteAt;

  Position? _lastProcessedPosition;
  static const double _minMoveMeters = 3.0;

  static const double stepProximityThreshold = 22.0;
  static const double offRouteThreshold = 35.0;
  static const double arrivalThreshold = 25.0;

  bool get isNavigating => _isNavigating;
  bool get isOffRoute => _isOffRoute;
  bool get hasArrived => _hasArrived;
  bool get isCalculatingRoute => _isCalculatingRoute;
  int get currentStepIndex => _currentStepIndex;
  double get remainingDistance => _remainingDistance;
  Duration get estimatedTimeRemaining => _estimatedTimeRemaining;
  String get currentInstruction => _currentInstruction;
  String? get error => _error;
  RouteDataModel? get activeRoute => _activeRoute;
  LatLng? get destination => _destination;
  List<LatLng> get routePoints => _activeRoute?.polylinePoints ?? const [];
  List<RouteStepModel> get steps => _activeRoute?.steps ?? const [];
  RouteStepModel? get currentStep =>
      steps.isNotEmpty && _currentStepIndex < steps.length
          ? steps[_currentStepIndex]
          : null;
  double get totalDistance => _activeRoute?.distanceMeters ?? 0.0;

  double get progress {
    final total = totalDistance;
    if (total <= 0) return 0.0;
    return ((total - _remainingDistance) / total).clamp(0.0, 1.0);
  }

  Future<void> startNavigation({
    required Position start,
    required LatLng destination,
    String destinationName = '',
  }) async {
    _destination = destination;
    _destinationName = destinationName;
    _hasArrived = false;
    _isNavigating = true;
    _currentStepIndex = 0;
    _nextWpIndex = 0;        // reset waypoints all'avvio
    _error = null;
    _lastProcessedPosition = null;
    await _buildRoute(start);
    notifyListeners();
  }

  /// Waypoints QR originali nell'ordine corretto.
  static final List<LatLng> _allQrWaypoints =
      kQrPoints.map((p) => p.latLng).toList();

  /// Indice del prossimo waypoint QR da raggiungere (0-based).
  /// Incrementato man mano che ci si avvicina a ciascun punto.
  int _nextWpIndex = 0;

  static const double _wpProximityM = 40.0; // metri per considerare un WP raggiunto

  /// Restituisce solo i waypoints non ancora raggiunti.
  List<LatLng> get _remainingWaypoints =>
      _allQrWaypoints.sublist(_nextWpIndex);

  Future<void> _buildRoute(Position start) async {
    if (_destination == null) return;
    _isCalculatingRoute = true;
    _error = null;
    notifyListeners();

    try {
      final route = await _routingService.fetchWalkingRoute(
        start: LatLng(start.latitude, start.longitude),
        end: _destination!,
        waypoints: _remainingWaypoints,
      );
      _activeRoute = route;
      _currentStepIndex = 0;
      _remainingDistance = route.distanceMeters;
      _estimatedTimeRemaining =
          Duration(seconds: route.durationSeconds.round());
      _currentInstruction = route.steps.isNotEmpty
          ? route.steps.first.instruction
          : 'Procedi verso la destinazione';
      _isOffRoute = false;
      _lastRerouteAt = DateTime.now();
      debugPrint('✅ Percorso: ${route.distanceMeters.round()}m, '
          '${route.steps.length} passi');
    } catch (e) {
      // Messaggio utente pulito, senza stack trace
      final raw = e.toString().replaceAll('Exception: ', '');
      final msg = raw.length > 140 ? '${raw.substring(0, 140)}...' : raw;
      debugPrint('❌ Errore routing: $msg');
      _error = msg;
      _currentInstruction = 'Impossibile calcolare il percorso';
      _activeRoute = null;
    } finally {
      _isCalculatingRoute = false;
      notifyListeners();
    }
  }

  Future<void> updatePosition(Position position) async {
    if (!_isNavigating || _destination == null || _isCalculatingRoute) return;

    final last = _lastProcessedPosition;
    if (last != null) {
      final moved = Geolocator.distanceBetween(
        last.latitude, last.longitude,
        position.latitude, position.longitude,
      );
      if (moved < _minMoveMeters) return;
    }
    _lastProcessedPosition = position;

    if (_activeRoute == null) {
      await _buildRoute(position);
      return;
    }

    final destDist = Geolocator.distanceBetween(
      position.latitude, position.longitude,
      _destination!.latitude, _destination!.longitude,
    );

    if (destDist <= arrivalThreshold) {
      _hasArrived = true;
      _isNavigating = false;
      _remainingDistance = 0;
      _estimatedTimeRemaining = Duration.zero;
      // Messaggio dinamico con il nome della destinazione effettiva
      final name = _destinationName.isNotEmpty ? _destinationName : 'destinazione';
      _currentInstruction = '🎉 Sei arrivato a $name!';
      notifyListeners();
      return;
    }

    // Avanza l'indice dei waypoints se ci si avvicina abbastanza
    _advanceWaypoints(position);

    _syncCurrentStep(position);
    _remainingDistance = _calculateRemainingDistance(position);
    _estimatedTimeRemaining =
        Duration(seconds: (_remainingDistance / 1.4).round());
    _currentInstruction =
        currentStep?.instruction ?? 'Continua sul percorso';

    final offDist = _distanceFromPositionToPolyline(position);
    _isOffRoute = offDist > offRouteThreshold;

    final canReroute = _lastRerouteAt == null ||
        DateTime.now().difference(_lastRerouteAt!).inSeconds >= 8;
    if (_isOffRoute && canReroute) {
      await _buildRoute(position);
      if (_activeRoute != null) _currentInstruction = '⚠️ Percorso ricalcolato';
    }

    notifyListeners();
  }

  void _advanceWaypoints(Position position) {
    while (_nextWpIndex < _allQrWaypoints.length) {
      final wp = _allQrWaypoints[_nextWpIndex];
      final d = Geolocator.distanceBetween(
          position.latitude, position.longitude, wp.latitude, wp.longitude);
      if (d <= _wpProximityM) {
        _nextWpIndex++;
      } else {
        break;
      }
    }
  }

  void _syncCurrentStep(Position position) {
    if (steps.isEmpty) return;
    int bestIndex = _currentStepIndex;
    double bestDist = double.infinity;
    for (int i = _currentStepIndex; i < steps.length; i++) {
      final d = Geolocator.distanceBetween(
        position.latitude, position.longitude,
        steps[i].location.latitude, steps[i].location.longitude,
      );
      if (d < bestDist) {
        bestDist = d;
        bestIndex = i;
      }
    }
    if (bestDist < stepProximityThreshold || bestIndex > _currentStepIndex) {
      _currentStepIndex = bestIndex;
    }
  }

  double _calculateRemainingDistance(Position position) {
    double remaining = 0.0;
    final step = currentStep;
    if (step != null) {
      remaining += Geolocator.distanceBetween(
        position.latitude, position.longitude,
        step.location.latitude, step.location.longitude,
      );
    }
    for (int i = _currentStepIndex; i < steps.length; i++) {
      remaining += steps[i].distance;
    }
    return remaining;
  }

  double _distanceFromPositionToPolyline(Position position) {
    if (routePoints.isEmpty) return 0.0;
    double minDist = double.infinity;
    for (final point in routePoints) {
      final d = Geolocator.distanceBetween(
        position.latitude, position.longitude,
        point.latitude, point.longitude,
      );
      if (d < minDist) minDist = d;
    }
    return minDist;
  }

  String getFormattedETA() {
    if (_estimatedTimeRemaining.inHours > 0) {
      return '${_estimatedTimeRemaining.inHours}h '
          '${_estimatedTimeRemaining.inMinutes % 60}m';
    }
    if (_estimatedTimeRemaining.inMinutes > 0) {
      return '${_estimatedTimeRemaining.inMinutes} min';
    }
    return '${_estimatedTimeRemaining.inSeconds} sec';
  }

  String getFormattedDistance() {
    if (_remainingDistance >= 1000) {
      return '${(_remainingDistance / 1000).toStringAsFixed(1)} km';
    }
    return '${_remainingDistance.round()} m';
  }

  void stopNavigation() {
    _isNavigating = false;
    notifyListeners();
  }
}
