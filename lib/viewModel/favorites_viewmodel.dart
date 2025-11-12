import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FavoritesViewModel with ChangeNotifier {
  final List<Map<String, dynamic>> _favoriteCourts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get favoriteCourts => _favoriteCourts;
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

  // Check if a court is in favorites
  bool isCourtInFavorites(Map<String, dynamic> court) {
    final courtId = court['place_id'] ?? court['id'];
    return _favoriteCourts.any((favCourt) => 
        (favCourt['place_id'] ?? favCourt['id']) == courtId);
  }

  // For tests - exactly what the test expects
  void toggleFavorite(Map<String, dynamic> court) {
    final isCurrentlyFavorite = isCourtInFavorites(court);
    
    if (isCurrentlyFavorite) {
      removeFromFavorites(court);
    } else {
      addToFavorites(court);
    }
  }

  // For UI with snackbar - different method name to avoid conflict
  void toggleFavoriteWithSnackbar(BuildContext context, Map<String, dynamic> court) {
    toggleFavorite(court); // Reuse the test-compatible method
    _showSnackbar(context, isCourtInFavorites(court) ? 'Added to favorites' : 'Removed from favorites');
  }

  // Add court to favorites
  void addToFavorites(Map<String, dynamic> court) {
    if (!isCourtInFavorites(court)) {
      _favoriteCourts.add(court);
      notifyListeners();
      _saveFavoritesToStorage();
    }
  }

  // Remove court from favorites
  void removeFromFavorites(Map<String, dynamic> court) {
    final courtId = court['place_id'] ?? court['id'];
    _favoriteCourts.removeWhere((favCourt) => 
        (favCourt['place_id'] ?? favCourt['id']) == courtId);
    notifyListeners();
    _saveFavoritesToStorage();
  }

  // For tests - exactly what the test expects
  void clearFavorites() {
    _favoriteCourts.clear();
    notifyListeners();
    _saveFavoritesToStorage();
  }

  // For UI - alias that matches the test method
  void clearAllFavorites() => clearFavorites();

  // Get favorite by ID
  Map<String, dynamic>? getFavoriteById(String courtId) {
    try {
      return _favoriteCourts.firstWhere(
        (court) => (court['place_id'] ?? court['id']) == courtId,
      );
    } catch (e) {
      return null;
    }
  }

  // Load favorites from storage (simulated)
  Future<void> loadFavorites() async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('Failed to load favorites: ${e.toString()}');
    }
  }

  // Save favorites to storage (simulated)
  Future<void> _saveFavoritesToStorage() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      _setError('Failed to save favorites: ${e.toString()}');
    }
  }

  // Show snackbar feedback
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}