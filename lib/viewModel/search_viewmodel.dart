import '../services/CourtsService.dart';

class SearchViewModel {
  final CourtsService _courtsService = CourtsService();
  List<String> searchHistory = [];
  bool isLoading = false;
  String? error;
  List<Map<String, dynamic>> courts = [];

  Future<void> searchCourts(String query) async {
    if (query.isEmpty) return;

    isLoading = true;
    error = null;
    searchHistory.add(query);
    courts.clear(); // Clear previous results

    try {
      final location = await _courtsService.geocodePlace(query);
      final results = await _courtsService.findPickleballCourts(
        location['lat']!,
        location['lng']!,
      );
      
      // Store the results in the courts list
      courts = results;
      
    } catch (e) {
      error = e.toString();
      print('Error searching for courts: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<void> getCourtsByLocation(lat, lng) async {
    isLoading = true;
    error = null;
    courts.clear(); // Clear previous results

    try {
      print('Searching for pickleball courts by location: $lat $lng');
      final results = await _courtsService.findPickleballCourts(
        lat,
        lng,
      );
      
      // Store the results in the courts list
      courts = results;
    } catch (e) {
      error = e.toString();
      print('Error searching for courts: $e');
    } finally {
      isLoading = false;
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
  }

  int get courtCount => courts.length;
}