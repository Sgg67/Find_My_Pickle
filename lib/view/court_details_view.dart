import 'package:find_my_pickle/viewModel/favorites_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class CourtDetailPage extends StatefulWidget {
  final Map<String, dynamic> court;

  const CourtDetailPage({Key? key, required this.court}) : super(key: key);

  @override
  State<CourtDetailPage> createState() => _CourtDetailPageState();
}

class _CourtDetailPageState extends State<CourtDetailPage> {
  @override
  Widget build(BuildContext context) {
    final name = widget.court['name'] ?? 'Unknown Court';
    final vicinity = widget.court['vicinity'] ?? 'No address available';
    final photoUrl = widget.court['photo_url'];
    final rating = widget.court['rating']?.toString() ?? 'No rating';
    final types = widget.court['types'] as List<dynamic>? ?? [];
    final openNow = widget.court['opening_hours']?['open_now'] as bool?;
    final geometry = widget.court['geometry'];
    final location = geometry?['location'];

    return Scaffold(
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
              // Court Image
              Container(
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

              // Court Details
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

                    // Rating
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

                    // Address Section
                    _buildDetailSection(
                      icon: Icons.location_on,
                      title: 'Address',
                      content: vicinity,
                    ),
                    // Action Buttons
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _openDirections(context, name, vicinity);
                            },
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
                            onPressed: () {
                              _showShareMessage(context);
                            },
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                          ),
                        ),
                      ],
                    ),
                    
                    // Extra padding at the bottom to ensure content is fully visible
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

  Widget _buildFavoriteButton() {
    return Consumer<FavoritesViewModel>(
      builder: (context, favoritesViewModel, child) {
        final isFavorite = favoritesViewModel.isCourtInFavorites(widget.court);

        return IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.white,
          ),
          onPressed: () {
            favoritesViewModel.toggleFavorite(widget.court);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isFavorite ? 'Removed from favorites' : 'Added to favorites'
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openDirections(BuildContext context, String name, String address) async {
    final geometry = widget.court['geometry'];
    final location = geometry?['location'];
    
    if (location != null) {
      final double? lat = location['lat']?.toDouble();
      final double? lng = location['lng']?.toDouble();
      
      if (lat != null && lng != null) {
        // Option 1: Open with coordinates (most accurate)
        final String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
        final String appleMapsUrl = 'https://maps.apple.com/?daddr=$lat,$lng&dirflg=d';
        
        // Option 2: Open with address (fallback)
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
            _showNoMapsAppDialog(context);
          }
        } catch (e) {
          _showNoMapsAppDialog(context);
        }
      } else {
        // Fallback to address-based navigation if coordinates aren't available
        final String addressMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$name $address')}';
        
        try {
          if (await canLaunchUrl(Uri.parse(addressMapsUrl))) {
            await launchUrl(Uri.parse(addressMapsUrl));
          } else {
            _showNoMapsAppDialog(context);
          }
        } catch (e) {
          _showNoMapsAppDialog(context);
        }
      }
    } else {
      // If no geometry data, use address
      final String addressMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$name $address')}';
      
      try {
        if (await canLaunchUrl(Uri.parse(addressMapsUrl))) {
          await launchUrl(Uri.parse(addressMapsUrl));
        } else {
          _showNoMapsAppDialog(context);
        }
      } catch (e) {
        _showNoMapsAppDialog(context);
      }
    }
  }

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

  Future<void> _showShareMessage(BuildContext context) async {
    final name = widget.court['name'] ?? 'Unknown Court';
    final vicinity = widget.court['vicinity'] ?? 'No adress available';
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
      _showShareError();
    }
  }

  void _showShareError(){
     ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to share at the moment. Please try again.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}