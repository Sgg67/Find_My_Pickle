import 'package:flutter/foundation.dart';
import '../services/CourtsService.dart';

class SearchViewModel with ChangeNotifier {
  final CourtsService _courtsService = CourtsService();
  
  // KEEP AS PUBLIC VARIABLES FOR TEST COMPATIBILITY
  List<String> searchHistory = [];
  bool isLoading = false;
  String? error;
  List<Map<String, dynamic>> courts = [];

  int get courtCount => courts.length;

  Future<void> searchCourts(String query) async {
    if (query.isEmpty) return;

    isLoading = true;
    error = null;
    courts.clear(); // Clear previous results
    notifyListeners();

    try {
      final location = await _courtsService.geocodePlace(query);
      final results = await _courtsService.findPickleballCourts(
        location['lat']!,
        location['lng']!,
      );
      
      // Store the results in the courts list
      courts = results;
      searchHistory.add(query);
      notifyListeners();
      
    } catch (e) {
      error = e.toString();
      if (kDebugMode) {
        print('Error searching for courts: $e');
      }
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCourtsByLocation(double lat, double lng) async {
    isLoading = true;
    error = null;
    courts.clear(); // Clear previous results
    notifyListeners();

    try {
      if (kDebugMode) {
        print('Searching for pickleball courts by location: $lat $lng');
      }
      
      final results = await _courtsService.findPickleballCourts(lat, lng);
      courts = results;
      notifyListeners();
      
    } catch (e) {
      error = e.toString();
      if (kDebugMode) {
        print('Error searching for courts: $e');
      }
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<String> getSearchSuggestions(String query) {
    if (query.isEmpty) return searchHistory.reversed.toList();
    return searchHistory
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void clearCourts() {
    courts.clear();
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}