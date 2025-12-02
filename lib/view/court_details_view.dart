import 'package:find_my_pickle/view/join_a_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:find_my_pickle/viewModel/favorites_viewmodel.dart';
import 'package:find_my_pickle/viewModel/directions_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

class CourtDetailPage extends StatefulWidget {
  final Map<String, dynamic> court;

  const CourtDetailPage({super.key, required this.court});

  @override
  State<CourtDetailPage> createState() => _CourtDetailPageState();
}

class _CourtDetailPageState extends State<CourtDetailPage> {
  late DirectionsViewModel _directionsViewModel;

  bool _isGuestUser() {
    final user = FirebaseAuth.instance.currentUser;
    return user == null || user.isAnonymous;
  }

  void _showGuestUserError() {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Guest users cannot join games. Please create an account to join games.',
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _directionsViewModel = DirectionsViewModel();
  }

  @override
  Widget build(BuildContext context) {
    // add the details of a particular court
    final name = widget.court['name'] ?? 'Unknown Court';
    final vicinity = widget.court['vicinity'] ?? 'No address available';
    final photoUrl = widget.court['photo_url'];
    final rating = widget.court['rating']?.toString() ?? 'No rating';
    final openNow = widget.court['opening_hours']?['open_now'] as bool?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Court Details'),
        backgroundColor: Colors.blue,
        actions: [_buildFavoriteButton()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: photoUrl ?? name,
                child: SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: photoUrl != null
                      ? Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
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
              ),

              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutQuart,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: Padding(
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
                          Text(rating, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 16),
                          if (openNow != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
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

                      // Address
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
                                HapticFeedback.lightImpact(); // Haptic
                                _handleGetDirections(context, name, vicinity);
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
                                HapticFeedback.lightImpact(); // Haptic
                                _handleShare(context);
                              },
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact(); // Stronger Haptic
                            if (_isGuestUser()) {
                              _showGuestUserError(); 
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      JoinAGame(court: widget.court),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.sports_tennis),
                          label: const Text('Join a Game'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }

  Widget _buildFavoriteButton() {
    return Consumer<FavoritesViewModel>(
      builder: (context, favoritesViewModel, child) {
        final isFavorite = favoritesViewModel.isCourtInFavorites(widget.court);

        return IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isFavorite), // Key detects change for animation
              color: isFavorite ? Colors.red : Colors.white,
            ),
          ),
          onPressed: () {
            HapticFeedback.selectionClick(); // Toggle Haptic
            _handleFavoriteToggle(context, favoritesViewModel, isFavorite);
          },
        );
      },
    );
  }

  Future<void> _handleGetDirections(
    BuildContext context,
    String name,
    String address,
  ) async {
    try {
      await _directionsViewModel.openDirections(
        court: widget.court,
        name: name,
        address: address,
      );
    } catch (e) {
      HapticFeedback.heavyImpact(); // Error Haptic
      _showNoMapsAppDialog(context);
    }
  }

  void _handleFavoriteToggle(
    BuildContext context,
    FavoritesViewModel favoritesViewModel,
    bool isFavorite,
  ) {
    favoritesViewModel.toggleFavorite(widget.court);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? 'Removed from favorites' : 'Added to favorites',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleShare(BuildContext context) async {
    final name = widget.court['name'] ?? 'Unknown Court';
    final vicinity = widget.court['vicinity'] ?? 'No address available';
    final rating = widget.court['rating']?.toString() ?? 'No rating';

    final String shareText =
        '''
    🏓 Check out this pickleball court!

    $name
    ⭐ Rating: $rating
    📍 Address: $vicinity

    Found via Find My Pickle app!''';

    try {
      await Share.share(shareText, subject: "Pickleball Court: $name");
    } catch (e) {
      HapticFeedback.heavyImpact(); // Error Haptic
      _showShareError(context);
    }
  }

  void _showNoMapsAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Maps App Found'),
        content: const Text(
          'Please install Google Maps or another navigation app to get directions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showShareError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to share at the moment. Please try again.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}