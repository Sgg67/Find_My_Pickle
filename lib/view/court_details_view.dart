// add necessary libraries and view models
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:find_my_pickle/viewModel/favorites_viewModel.dart';
import 'package:find_my_pickle/viewModel/directions_viewModel.dart'; // Add this import

class CourtDetailPage extends StatefulWidget {
  // declare a map for a court
  final Map<String, dynamic> court;

  const CourtDetailPage({super.key, required this.court});

  @override
  State<CourtDetailPage> createState() => _CourtDetailPageState();
}

class _CourtDetailPageState extends State<CourtDetailPage> {
  // Initialize Directions view model
  late DirectionsViewModel _directionsViewModel;

  // initialize the directions view model
  @override
  void initState() {
    super.initState();
    _directionsViewModel = DirectionsViewModel();
  }

  @override
  Widget build(BuildContext context) {
    // necessary variables that will be used in UI
    final name = widget.court['name'] ?? 'Unknown Court';
    final vicinity = widget.court['vicinity'] ?? 'No address available';
    final photoUrl = widget.court['photo_url'];
    final rating = widget.court['rating']?.toString() ?? 'No rating';
    final openNow = widget.court['opening_hours']?['open_now'] as bool?;

    return Scaffold(
      // add a blue app bar
      appBar: AppBar(
        title: const Text('Court Details'),
        backgroundColor: Colors.blue,
        actions: [
          _buildFavoriteButton(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              SizedBox(
                height: 250,
                width: double.infinity,
                child: photoUrl != null
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.sports_tennis,
                              size: 80,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.sports_tennis,
                          size: 80,
                          color: Colors.grey[600],
                        ),
                      ),
              ),

              // Details section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Court Name
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Rating in the details section
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 16),
                        if (openNow != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: openNow ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              openNow ? 'OPEN' : 'CLOSED',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Adress is on the details section
                    _buildDetailSection(
                      icon: Icons.location_on,
                      title: 'Address',
                      content: vicinity,
                    ),

                    // Directions and Share Buttons
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleGetDirections(context, name, vicinity),
                            icon: const Icon(Icons.directions),
                            label: const Text('Get Directions'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _handleShare(context),
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // details section background set up
  Widget _buildDetailSection({required IconData icon, required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // add the favorite button on the top of the screen so you can add to favorites
  Widget _buildFavoriteButton() {
    return Consumer<FavoritesViewModel>(
      builder: (context, favoritesViewModel, child) {
        final isFavorite = favoritesViewModel.isCourtInFavorites(widget.court);

        return IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.white,
          ),
          onPressed: () => _handleFavoriteToggle(context, favoritesViewModel, isFavorite),
        );
      },
    );
  }

  // call the view model for directions
  Future<void> _handleGetDirections(BuildContext context, String name, String address) async {
    try {
      await _directionsViewModel.openDirections(
        court: widget.court,
        name: name,
        address: address,
      );
    } catch (e) {
      _showNoMapsAppDialog(context);
    }
  }

  // set up UI logic when something is favorited and then clicked again
  void _handleFavoriteToggle(BuildContext context, FavoritesViewModel favoritesViewModel, bool isFavorite) {
    favoritesViewModel.toggleFavorite(widget.court);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? 'Removed from favorites' : 'Added to favorites'
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // UI logic for sharing a court
  Future<void> _handleShare(BuildContext context) async {
    final name = widget.court['name'] ?? 'Unknown Court';
    final vicinity = widget.court['vicinity'] ?? 'No address available';
    final rating = widget.court['rating']?.toString() ?? 'No rating';

    final String shareText = '''
    🏓 Check out this pickleball court!

    $name
    ⭐ Rating: $rating
    📍 Address: $vicinity

    Found via Find My Pickle app!''';

    try {
      await Share.share(
        shareText,
        subject: "Pickleball Court: $name",
      );
    } catch(e) {
      _showShareError(context);
    }
  }

  // UI-only helper methods for dialogs and error messages
  void _showNoMapsAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Maps App Found'),
        content: const Text('Please install Google Maps or another navigation app to get directions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // show on the screen when you can not share a court
  void _showShareError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to share at the moment. Please try again.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}