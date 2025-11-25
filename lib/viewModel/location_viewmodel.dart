import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationViewModel with ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = false;
  String? _errorMessage;

  Position? get currentPosition => _currentPosition;
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

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check current permission status
  Future<LocationPermission> checkPermissionStatus() async {
    return await Geolocator.checkPermission();
  }

  // Request location permission
  Future<LocationPermission> requestPermission() async {
    _setLoading(true);
    try {
      final permission = await Geolocator.requestPermission();
      _setLoading(false);
      return permission;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to request location permission: ${e.toString()}');
      rethrow;
    }
  }

  // Get location coordinates (with permission handling)
  Future<Map<String, dynamic>> getCurrentCoordinates() async {
    _setLoading(true);
    _setError(null);
    
    try {
      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setLoading(false);
        _setError('Location services are disabled');
        return {
          'success': false,
          'message': 'Location services are disabled',
        };
      }

      // Check and request permission if needed
      LocationPermission permission = await checkPermissionStatus();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
      }

      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        _setLoading(false);
        _setError('Location permission denied');
        return {
          'success': false,
          'message': 'Location permission denied',
        };
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      _currentPosition = position;
      _setLoading(false);
      
      return {
        'success': true,
        'message': 'Latitude: ${position.latitude}\nLongitude: ${position.longitude}',
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      _setLoading(false);
      _setError('Error getting location: ${e.toString()}');
      return {
        'success': false,
        'message': 'Error getting location: $e',
      };
    }
  }

  // Simple method to check if we can get location
  Future<bool> canGetLocation() async {
    final serviceEnabled = await isLocationServiceEnabled();
    final permission = await checkPermissionStatus();
    
    return serviceEnabled && 
           (permission == LocationPermission.whileInUse || 
            permission == LocationPermission.always);
  }

  // Get distance between two points
  Future<double?> getDistance(
    double startLat, 
    double startLng, 
    double endLat, 
    double endLng
  ) async {
    try {
      final distance = Geolocator.distanceBetween(
        startLat, startLng, endLat, endLng
      );
      return distance;
    } catch (e) {
      _setError('Error calculating distance: ${e.toString()}');
      return null;
    }
  }
}