import 'package:flutter/foundation.dart';

class FavoritesViewModel with ChangeNotifier{
  final List<Map<String, dynamic>> _favoriteCourts = [];
  List<Map<String, dynamic>> get favoriteCourts => _favoriteCourts;

  void addToFavorites(Map<String, dynamic> court) {
    if(!_isCourtInFavorites(court)) {
      _favoriteCourts.add(court);
      notifyListeners();
    }
  }

  void removeFromFavorites(Map<String, dynamic> court) {
    _favoriteCourts.removeWhere((favCourt) => 
      favCourt['place_id'] == court['place_id']);
      notifyListeners();
  }

  bool isCourtInFavorites(Map<String, dynamic> court) {
    return _isCourtInFavorites(court);
  }

  void toggleFavorite(Map<String, dynamic> court) {
    if(isCourtInFavorites(court)) {
      removeFromFavorites(court);
    } else {
      addToFavorites(court);
    }
  }

  void clearFavorites() {
    _favoriteCourts.clear();
    notifyListeners();
  }

  bool _isCourtInFavorites(Map<String, dynamic> court) {
    return _favoriteCourts.any((favCourt) => 
      favCourt['place_id'] == court['place_id']);
  }
}