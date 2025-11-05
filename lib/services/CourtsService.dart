import 'dart:convert';
import 'package:http/http.dart' as http;

class CourtsService {
  static const String _apiKey = "AIzaSyD_ocE7U54PBsbwJh4E3SbhhknQm0OiGNg";
  static const String _keyword = "pickleball court";
  static const int _radius = 16000;

  Future<Map<String, double>> geocodePlace(String place) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      {
        'address': place,
        'key': _apiKey,
      },
    );
    final response = await http.get(uri);
    final data = jsonDecode(response.body);
    
    if(data['status'] == 'OK'){
      final location = data['results'][0]['geometry']['location'];
      return {
        'lat': location['lat'].toDouble(), 
        'lng': location['lng'].toDouble(), 
      };
    } else {
      throw Exception('Geocoding failed: ${data['status']}');
    }
  }

  Future<List<Map<String, dynamic>>> findPickleballCourts(double lat, double lng) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/nearbysearch/json',
      {
        'location': '$lat,$lng',
        'radius': _radius.toString(),
        'keyword': _keyword,
        'key': _apiKey,
      },
    );

    final response = await http.get(uri);
    final data = jsonDecode(response.body);
    
    List<Map<String, dynamic>> results;
    if(data['status'] == 'OK'){ 
      results = List<Map<String, dynamic>>.from(data['results'] ?? []);
    } else {
      throw Exception('Places API failed: ${data['status']}');
    }

    // Add photo URLs to each court
    for(var court in results){
      if(court['photos'] != null && (court['photos'] as List).isNotEmpty){
        final photoReference = court['photos'][0]['photo_reference']; // Fixed typo: 'phot_reference' to 'photo_reference'
        court['photo_url'] = _getPlacePhotoUrl(photoReference);
      }
    }

    return results;
  }

  String _getPlacePhotoUrl(String photoReference, {int maxWidth = 400}) {
    return Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/photo',
      {
        'photo_reference': photoReference,
        'maxwidth': maxWidth.toString(),
        'key': _apiKey, // Fixed: changed 'apiKey' to '_apiKey'
      },
    ).toString();
  }

  List<String> getPlacePhotos(List<dynamic> photos, {int maxWidth = 400}) {
    final List<String> photoUrls = [];

    for(var photo in photos.take(3)) {
      final photoReference = photo['photo_reference'];
      final url = _getPlacePhotoUrl(photoReference, maxWidth: maxWidth);
      photoUrls.add(url);
    }
    
    return photoUrls; 
  }
}