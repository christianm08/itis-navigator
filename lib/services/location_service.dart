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
        _isLoading = false;
        notifyListeners();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _error = 'Permesso posizione negato';
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _error = 'Permesso posizione negato definitivamente. Apri le impostazioni.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 0,
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Timeout nel recupero della posizione');
        },
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
      // Non propagare l'errore - l'app continua a funzionare
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
        debugPrint('⚠️ Errore stream posizione: $error');
        // Non mostrare errore all'utente se il tracking è già attivo
        if (_currentPosition == null) {
          _error = 'Errore nel tracciamento posizione';
          notifyListeners();
        }
      },
      cancelOnError: false, // Continua il tracking anche con errori
    );
  }

  void _startCompassTracking() {
    try {
      _compassStreamSubscription = FlutterCompass.events?.listen(
        (event) {
          if (event.heading != null) {
            _heading = event.heading;
            notifyListeners();
          }
        },
        onError: (error) {
          debugPrint('⚠️ Errore bussola: $error');
          // Bussola non critica - ignora errori
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('⚠️ Bussola non disponibile: $e');
      // Continua senza bussola
    }
  }

  Future<void> forceRefreshPosition() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 0,
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Timeout aggiornamento posizione');
        },
      );
      _error = null;
      notifyListeners();
    } on TimeoutException {
      _error = 'Timeout nel recupero della posizione';
      notifyListeners();
    } catch (e) {
      _error = 'Errore aggiornamento posizione: $e';
      debugPrint('⚠️ forceRefreshPosition error: $e');
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
