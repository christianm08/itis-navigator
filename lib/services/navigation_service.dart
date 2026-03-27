import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/route_data_model.dart';
import '../screens/qr_scanner_screen.dart' show kQrPoints;
import 'routing_service.dart';
import 'tts_service.dart';

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

  /// Indice snap sulla polilinea — usato per la finestra locale off-route.
  int _polylineSnapIndex = 0;

  /// Riferimento al servizio TTS per gli annunci vocali.
  TtsService? _ttsService;

  Position? _lastProcessedPosition;
  static const double _minMoveMeters = 3.0;

  /// true se startNavigation ha usato la posizione di fallback (GPS non pronto).
  /// Appena arriva la prima posizione GPS reale, ricalcoliamo subito il percorso.
  bool _startedFromFallback = false;

  static const double stepProximityThreshold = 22.0;
  static const double offRouteThreshold = 40.0;
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

  /// Collega il servizio TTS. Chiamare prima di startNavigation.
  void attachTts(TtsService tts) {
    _ttsService = tts;
  }

  /// Annuncio vocale — no-op se TTS non collegato.
  void _announce(String text) {
    _ttsService?.speak(text);
  }

  Future<void> startNavigation({
    required Position start,
    required LatLng destination,
    String destinationName = '',
    bool fromFallback = false,
  }) async {
    _destination = destination;
    _destinationName = destinationName;
    _hasArrived = false;
    _isNavigating = true;
    _currentStepIndex = 0;
    _nextWpIndex = 0;
    _polylineSnapIndex = 0;
    _error = null;
    _lastProcessedPosition = null;
    _startedFromFallback = fromFallback;
    await _buildRoute(start);

    final name = _destinationName.isNotEmpty ? _destinationName : 'destinazione';
    _announce('Navigazione avviata verso $name. '
        'Distanza: ${getFormattedDistance()}. '
        'Tempo stimato: ${getFormattedETA()}.');

    notifyListeners();
  }

  /// Waypoints QR originali nell'ordine corretto.
  static final List<LatLng> _allQrWaypoints =
      kQrPoints.map((p) => p.latLng).toList();

  int _nextWpIndex = 0;
  static const double _wpProximityM = 40.0;

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
      _polylineSnapIndex = 0;
      _remainingDistance = route.distanceMeters;
      _estimatedTimeRemaining =
          Duration(seconds: route.durationSeconds.round());
      _currentInstruction = route.steps.isNotEmpty
          ? route.steps.first.instruction
          : 'Procedi verso la destinazione';
      _isOffRoute = false;
      _lastRerouteAt = DateTime.now();
      if (kDebugMode) {
        debugPrint('✅ Percorso: ${route.distanceMeters.round()}m, '
            '${route.steps.length} passi');
      }
    } catch (e) {
      final raw = e.toString().replaceAll('Exception: ', '');
      final msg = raw.length > 140 ? '${raw.substring(0, 140)}...' : raw;
      if (kDebugMode) debugPrint('❌ Errore routing: $msg');
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

    if (_startedFromFallback) {
      _startedFromFallback = false;
      if (kDebugMode) {
        debugPrint('📍 GPS reale ricevuto — ricalcolo percorso da posizione attuale');
      }
      await _buildRoute(position);
      return;
    }

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
      final name = _destinationName.isNotEmpty ? _destinationName : 'destinazione';
      _currentInstruction = '🎉 Sei arrivato a $name!';
      _announce('Sei arrivato a $name.');
      notifyListeners();
      return;
    }

    // Salva stato precedente per notifyListeners condizionale
    final prevStepIndex = _currentStepIndex;
    final prevInstruction = _currentInstruction;
    final prevOffRoute = _isOffRoute;

    _advanceWaypoints(position);

    // Loop fuso: step sync + distanza rimanente in una sola passata
    _updateStepAndDistance(position);

    _estimatedTimeRemaining =
        Duration(seconds: (_remainingDistance / 1.4).round());
    _currentInstruction =
        currentStep?.instruction ?? 'Continua sul percorso';

    if (_currentStepIndex != prevStepIndex && currentStep != null) {
      _announce(currentStep!.instruction);
    }

    // Off-route: finestra locale ±20 punti attorno allo snap index
    final offDist = _distanceFromPositionToPolylineWindowed(position);
    _isOffRoute = offDist > offRouteThreshold;

    final canReroute = _lastRerouteAt == null ||
        DateTime.now().difference(_lastRerouteAt!).inSeconds >= 3;
    if (_isOffRoute && canReroute) {
      _announce('Sei fuori percorso. Ricalcolo in corso.');
      await _buildRoute(position);
      if (_activeRoute != null) _currentInstruction = '⚠️ Percorso ricalcolato';
    }

    // notifyListeners solo se lo stato visibile è cambiato
    if (_currentStepIndex != prevStepIndex ||
        _currentInstruction != prevInstruction ||
        _isOffRoute != prevOffRoute) {
      notifyListeners();
    }
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

  /// Fonde _syncCurrentStep e _calculateRemainingDistance in un singolo loop,
  /// eliminando la doppia scansione degli step ad ogni update GPS.
  void _updateStepAndDistance(Position position) {
    if (steps.isEmpty) {
      _remainingDistance = 0;
      return;
    }

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

    // Calcola distanza rimanente: distanza al prossimo step + somma step successivi
    double remaining = bestDist;
    for (int i = _currentStepIndex; i < steps.length; i++) {
      remaining += steps[i].distance;
    }
    _remainingDistance = remaining;
  }

  /// Controlla l'off-route su una finestra locale di ±20 punti attorno
  /// all'ultimo snap index noto, invece di scansionare l'intera polilinea.
  double _distanceFromPositionToPolylineWindowed(Position position) {
    final pts = routePoints;
    if (pts.isEmpty) return 0.0;

    // Aggiorna snap index nella finestra corrente
    final winStart = (_polylineSnapIndex - 20).clamp(0, pts.length - 1);
    final winEnd = (_polylineSnapIndex + 20).clamp(0, pts.length - 1);

    double minDist = double.infinity;
    int minIndex = _polylineSnapIndex;

    for (int i = winStart; i <= winEnd; i++) {
      final d = Geolocator.distanceBetween(
        position.latitude, position.longitude,
        pts[i].latitude, pts[i].longitude,
      );
      if (d < minDist) {
        minDist = d;
        minIndex = i;
      }
    }
    _polylineSnapIndex = minIndex;
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
    _ttsService?.stop();
    notifyListeners();
  }
}
