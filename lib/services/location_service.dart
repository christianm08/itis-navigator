import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../constants/app_strings.dart';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;
  double? _heading;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<CompassEvent>? _compassStreamSubscription;
  bool _isInitialized = false;

  // Debounce bussola: notifica solo se heading cambia di almeno 5 gradi
  double? _lastNotifiedHeading;
  static const double _headingThreshold = AppStrings.headingThreshold;

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double? get heading => _heading;
  bool get isInitialized => _isInitialized;
  bool get hasError => _error != null;

  Future<void> initialize() async {
    if (_isInitialized && _currentPosition != null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = AppStrings.permissionLocationDisabled;
        _isLoading = false;
        notifyListeners();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _error = AppStrings.permissionLocationDenied;
        _isLoading = false;
        notifyListeners();
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _error = AppStrings.permissionLocationDeniedForever;
        _isLoading = false;
        notifyListeners();
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      ).timeout(
        const Duration(seconds: AppStrings.httpTimeoutSeconds),
        onTimeout: () => throw TimeoutException('Timeout GPS'),
      );

      await _positionStreamSubscription?.cancel();
      await _compassStreamSubscription?.cancel();

      _startLocationTracking();
      _startCompassTracking();
      _isInitialized = true;
    } on TimeoutException catch (e) {
      _error = 'Timeout GPS: verifica la connessione satellite';
      debugPrint('⚠️ LocationService timeout: $e');
    } catch (e) {
      _error = 'GPS temporaneamente non disponibile';
      debugPrint('⚠️ LocationService error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startLocationTracking() {
    // distanceFilter: 5m - notifica solo ogni 5 metri (era 1m)
    // Riduce drasticamente il numero di rebuild della UI
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: AppStrings.gpsDistanceFilter,
      ),
    ).listen(
      (position) {
        _currentPosition = position;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('⚠️ Errore stream posizione: $error');
        if (_currentPosition == null) {
          _error = AppStrings.locationError;
          notifyListeners();
        }
      },
      cancelOnError: false,
    );
  }

  void _startCompassTracking() {
    try {
      _compassStreamSubscription = FlutterCompass.events?.listen(
        (event) {
          final newHeading = event.heading;
          if (newHeading == null) return;

          // Notifica solo se heading cambia di almeno 5 gradi
          // Evita decine di notifyListeners() al secondo
          final last = _lastNotifiedHeading;
          if (last == null || (newHeading - last).abs() >= _headingThreshold) {
            _heading = newHeading;
            _lastNotifiedHeading = newHeading;
            notifyListeners();
          }
        },
        onError: (error) => debugPrint('⚠️ Errore bussola: $error'),
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('⚠️ Bussola non disponibile: $e');
    }
  }

  Future<void> forceRefreshPosition() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      ).timeout(
        const Duration(seconds: AppStrings.httpTimeoutSeconds),
        onTimeout: () => throw TimeoutException('Timeout aggiornamento'),
      );
      _error = null;
      notifyListeners();
    } on TimeoutException {
      _error = 'Timeout nel recupero della posizione';
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ forceRefreshPosition error: $e');
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _compassStreamSubscription?.cancel();
    super.dispose();
  }
}
