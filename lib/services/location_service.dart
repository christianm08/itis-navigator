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
  bool _isInitialized = false;

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double? get heading => _heading;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized && _currentPosition != null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'Attiva i servizi di localizzazione del dispositivo';
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _error = 'Permesso posizione negato';
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _error = 'Permesso posizione negato definitivamente. Apri le impostazioni.';
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      await _positionStreamSubscription?.cancel();
      await _compassStreamSubscription?.cancel();

      _startLocationTracking();
      _startCompassTracking();
      _isInitialized = true;
    } catch (e) {
      _error = 'Errore nel recupero della posizione: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startLocationTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 1,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (position) {
        _currentPosition = position;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Errore nel tracciamento posizione: $error';
        notifyListeners();
      },
    );
  }

  void _startCompassTracking() {
    _compassStreamSubscription = FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        _heading = event.heading;
        notifyListeners();
      }
    });
  }

  Future<void> forceRefreshPosition() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Errore aggiornamento posizione: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _compassStreamSubscription?.cancel();
    super.dispose();
  }
}
