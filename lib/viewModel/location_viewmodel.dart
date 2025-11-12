import 'package:geolocator/geolocator.dart';

class LocationViewModel {
  Position? currentPosition;
  bool isLoading = false;

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check current permission status
  Future<LocationPermission> checkPermissionStatus() async {
    return await Geolocator.checkPermission();
  }

  // Get location coordinates (assumes permissions are already granted)
  Future<Map<String, dynamic>> getCurrentCoordinates() async {
    isLoading = true;
    
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      
      currentPosition = position;
      isLoading = false;
      
      return {
        'success': true,
        'message': 'Latitude: ${position.latitude}\nLongitude: ${position.longitude}',
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      isLoading = false;
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
}