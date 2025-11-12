import 'package:flutter/foundation.dart';

class HomeViewModel with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Add home screen specific business logic here
  Future<void> loadHomeData() async {
    _setLoading(true);
    try {
      // Load featured courts, recent games, user stats, etc.
      await Future.delayed(Duration(milliseconds: 500)); // Simulate API call
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
    }
  }
}