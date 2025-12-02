import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:find_my_pickle/viewModel/location_viewmodel.dart';
import 'package:find_my_pickle/viewModel/search_viewmodel.dart';
import 'package:find_my_pickle/view/court_results_page.dart';

// create a view that is the results page for view that is clicked by location
class CourtResultsByLocation extends StatefulWidget {
  const CourtResultsByLocation({super.key});
  // create the result state
  @override
  State<CourtResultsByLocation> createState() => _CourtResultsByLocationState();
}

class _CourtResultsByLocationState extends State<CourtResultsByLocation> {
  final LocationViewModel _locationViewModel = LocationViewModel();
  final SearchViewModel _searchViewModel = SearchViewModel();
  bool _isSearching = false;
  
  Future<void> _getCurrentLocationAndCourts() async {
    setState(() {
      _isSearching = true;
    });

    try {
      // check to see if location is enabled
      final serviceEnabled = await _locationViewModel.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceError();
        return;
      }

      // request permission if not enabled
      final permission = await _handleLocationPermissions();
      if (!permission) {
        return;
      }

      // Get coordinates
      final locationResult = await _locationViewModel.getCurrentCoordinates();
      
      if (locationResult['success'] == true && _locationViewModel.currentPosition != null) {
        final lat = _locationViewModel.currentPosition!.latitude;
        final lng = _locationViewModel.currentPosition!.longitude;
        
        // Search for courts near a certain latitude and longitude
        await _searchViewModel.getCourtsByLocation(lat, lng);
        
        if (!mounted) return;
        
        // Navigate to the results page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourtResultsPage(
              courts: _searchViewModel.courts,
              searchQuery: 'your location',
            ),
          ),
        );
      } else {
        // Show error message if the results do not show up
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(locationResult['message'] ?? 'Failed to get location')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error finding courts: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  // request for permission for location
  Future<bool> _handleLocationPermissions() async {
    LocationPermission permission = await _locationViewModel.checkPermissionStatus();
    
    if (permission == LocationPermission.denied) {
      // Request permission - this must be done in the UI thread
      permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are required to find courts near you.')),
        );
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      _showPermissionPermanentlyDeniedDialog();
      return false;
    }
    
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }

  // show an error related to location
  void _showLocationServiceError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location services are disabled. Please enable them to find courts near you.'),
        duration: Duration(seconds: 5),
      ),
    );
    setState(() {
      _isSearching = false;
    });
  }

  void _showPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Required'),
        content: Text(
          'Location permissions are permanently denied. '
          'Please enable them in your device settings to find courts near you.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Courts Near You'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.my_location, size: 64, color: Colors.blue),
              SizedBox(height: 20),
              Text(
                'Courts near you',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              if (_isSearching)
                Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Finding your location and courts...'),
                    SizedBox(height: 8),
                  ],
                )
              else
                ElevatedButton.icon(
                  onPressed: _getCurrentLocationAndCourts,
                  icon: Icon(Icons.location_on),
                  label: Text('Find Courts Near You'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}