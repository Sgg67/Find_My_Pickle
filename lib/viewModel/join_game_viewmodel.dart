import 'package:flutter/foundation.dart';

class JoinGameViewModel with ChangeNotifier {
  List<dynamic> _availableGames = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get availableGames => _availableGames;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAvailableGames() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Load available games from service
      await Future.delayed(Duration(milliseconds: 800));
      _availableGames = []; // Replace with actual games data
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> joinGame(String gameId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Implement game joining logic
      await Future.delayed(Duration(milliseconds: 500));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}