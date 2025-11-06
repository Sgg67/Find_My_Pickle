// import data and http libraries
import 'dart:convert';
import 'package:http/http.dart' as http;

// get the pickleball courts near you using the google maps places api
class CourtsService {
  // add a const api key
  static const String _apiKey = "AIzaSyD_ocE7U54PBsbwJh4E3SbhhknQm0OiGNg";
  // set the key word to pickle ball courts
  static const String _keyword = "pickleball court";

  // set a radius of ~10 miles
  static const int _radius = 16000;

// this function turns the name of a place into latitude and longitude
  Future<Map<String, double>> geocodePlace(String place) async {
    // initialize the url
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      {
        'address': place,
        'key': _apiKey,
      },
    );
    // make the get request
    final response = await http.get(uri);
    // get the json data
    final data = jsonDecode(response.body);
    
    // get the latitude and longitude from the json data
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
  
  // use the google places api to get all the courts near a given latitude and longitude
  Future<List<Map<String, dynamic>>> findPickleballCourts(double lat, double lng) async {
    // initalize the url
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

    // call the api and get the json data
    final response = await http.get(uri);
    final data = jsonDecode(response.body);
    
    // add the list of pickleball courts to a list from the json data
    List<Map<String, dynamic>> results;
    if(data['status'] == 'OK'){ 
      results = List<Map<String, dynamic>>.from(data['results'] ?? []);
    } else {
      throw Exception('Places API failed: ${data['status']}');
    }

    // Add the url for photos for each court
    for(var court in results){
      if(court['photos'] != null && (court['photos'] as List).isNotEmpty){
        final photoReference = court['photos'][0]['photo_reference'];
        court['photo_url'] = _getPlacePhotoUrl(photoReference);
      }
    }

    return results;
  }

  // this api requests get the photo url for a given court
  String _getPlacePhotoUrl(String photoReference, {int maxWidth = 400}) {
    // creates the url to get the image url of a particular court
    return Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/photo',
      {
        'photo_reference': photoReference,
        'maxwidth': maxWidth.toString(),
        'key': _apiKey,
      },
    ).toString();
  }

  // add the photos to a list
  List<String> getPlacePhotos(List<dynamic> photos, {int maxWidth = 400}) {
    // initalize a list of photos
    final List<String> photoUrls = [];

    // loop through the photos url
    for(var photo in photos.take(3)) {
      // get the url for a photo from json
      final photoReference = photo['photo_reference'];
      // get the actual url of the photo that will be used to get the actual photo
      final url = _getPlacePhotoUrl(photoReference, maxWidth: maxWidth);
      /// add the photo url to the list of photos
      photoUrls.add(url);
    }
    // return the photos list
    return photoUrls; 
  }
}