import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;
  double? _heading;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<CompassEvent>? _compassStreamSubscription;

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double? get heading => _heading;

  Future<void> initialize() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'Servizi di localizzazione disabilitati';
        _isLoading = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'Permessi di localizzazione negati';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error = 'Permessi di localizzazione permanentemente negati';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      _startLocationTracking();
      _startCompassTracking();
    } catch (e) {
      _error = 'Errore nel recupero della posizione: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startLocationTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Aggiorna ogni 5 metri
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _currentPosition = position;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Errore nel tracciamento: $error';
        notifyListeners();
      },
    );
  }

  void _startCompassTracking() {
    _compassStreamSubscription = FlutterCompass.events?.listen(
      (CompassEvent event) {
        if (event.heading != null) {
          _heading = event.heading;
          notifyListeners();
        }
      },
    );
  }

  Future<void> updatePosition() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Errore nell\'aggiornamento della posizione: $e';
      notifyListeners();
    }
  }

  double calculateDistance(double lat, double lon) {
    if (_currentPosition == null) return 0.0;
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      lat,
      lon,
    );
  }

  double calculateBearing(double lat, double lon) {
    if (_currentPosition == null) return 0.0;
    return Geolocator.bearingBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      lat,
      lon,
    );
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _compassStreamSubscription?.cancel();
    super.dispose();
  }
}
