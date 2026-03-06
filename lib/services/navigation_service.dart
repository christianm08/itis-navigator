import 'package:flutter/foundation.dart';

class NavigationService extends ChangeNotifier {
  String _transportMode = 'walking';
  bool _isNavigating = false;

  String get transportMode => _transportMode;
  bool get isNavigating => _isNavigating;

  void setTransportMode(String mode) {
    _transportMode = mode;
    notifyListeners();
  }

  void startNavigation() {
    _isNavigating = true;
    notifyListeners();
  }

  void stopNavigation() {
    _isNavigating = false;
    notifyListeners();
  }
}
