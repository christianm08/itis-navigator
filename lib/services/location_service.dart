import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
    } catch (e) {
      _error = 'Errore nel recupero della posizione: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
}
