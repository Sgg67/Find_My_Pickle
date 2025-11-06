import 'package:url_launcher/url_launcher.dart';

class DirectionsViewModel {
  Future<void> openDirections({
    required Map<String, dynamic> court,
    required String name,
    required String address,
  }) async {
    final geometry = court['geometry'];
    final location = geometry?['location'];
    
    if (location != null) {
      final double? lat = location['lat']?.toDouble();
      final double? lng = location['lng']?.toDouble();
      
      if (lat != null && lng != null) {
        await _openWithCoordinates(lat, lng, name, address);
      } else {
        await _openWithAddress(name, address);
      }
    } else {
      await _openWithAddress(name, address);
    }
  }

  Future<void> _openWithCoordinates(
    double lat, 
    double lng, 
    String name, 
    String address
  ) async {
    final String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
    final String appleMapsUrl = 'https://maps.apple.com/?daddr=$lat,$lng&dirflg=d';
    final String addressMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$name $address')}';
    
    try {
      // Try Google Maps first
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl));
      } 
      // Try Apple Maps as fallback
      else if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
        await launchUrl(Uri.parse(appleMapsUrl));
      }
      // Try with address as last resort
      else if (await canLaunchUrl(Uri.parse(addressMapsUrl))) {
        await launchUrl(Uri.parse(addressMapsUrl));
      } else {
        throw Exception('No maps app available');
      }
    } catch (e) {
      throw Exception('No maps app available');
    }
  }

  Future<void> _openWithAddress(String name, String address) async {
    final String addressMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$name $address')}';
    
    try {
      if (await canLaunchUrl(Uri.parse(addressMapsUrl))) {
        await launchUrl(Uri.parse(addressMapsUrl));
      } else {
        throw Exception('No maps app available');
      }
    } catch (e) {
      throw Exception('No maps app available');
    }
  }
}