import 'package:flutter/foundation.dart';

/// Base class for services with common patterns
abstract class BaseService extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Set loading state
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Set error state
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Safe execute with error handling
  Future<T?> safeExecute<T>(
    Future<T> Function() operation, {
    String? errorMessage,
  }) async {
    try {
      setLoading(true);
      clearError();
      return await operation();
    } catch (e) {
      final error = errorMessage ?? e.toString();
      setError(error);
      if (kDebugMode) {
        debugPrint('⚠️ $runtimeType error: $error');
      }
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// Safe execute without loading state
  Future<T?> safeExecuteNoLoading<T>(
    Future<T> Function() operation, {
    String? errorMessage,
  }) async {
    try {
      return await operation();
    } catch (e) {
      final error = errorMessage ?? e.toString();
      setError(error);
      if (kDebugMode) {
        debugPrint('⚠️ $runtimeType error: $error');
      }
      return null;
    }
  }
}
