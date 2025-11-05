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
      print('Searching for pickleball courts near: $query');
      final location = await _courtsService.geocodePlace(query);
      final results = await _courtsService.findPickleballCourts(
        location['lat']!,
        location['lng']!,
      );
      
      // Store the results in the courts list
      courts = results;
      _printResults(query, courts);
      
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

  void _printResults(String query, List<Map<String, dynamic>> results) {
    print('\n=== PICKLEBALL COURTS FOUND ===');
    print('Location: $query');
    print('Number of courts found: ${results.length}');
    print('-----------------------------');

    for (var court in results) {
      final name = court['name'];
      final vicinity = court['vicinity'] ?? 'No address available'; // Fixed typo
      final hasPhoto = court['photo_url'] != null;
      
      print('🏸 $name');
      print('   📍 $vicinity');
      print('   📸 Has photo: $hasPhoto');
      if (hasPhoto) {
        print('   🖼️  Photo URL: ${court['photo_url']}');
      }
      print('---');
    }

    if (results.isEmpty) {
      print('No pickleball courts found in the specified area.');
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