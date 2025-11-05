import 'package:find_my_pickle/view/court_details_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewModel/favorites_viewModel.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.favorite, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('Favorite Courts'),
          ],
        ),
        backgroundColor: Colors.blue,
        actions: [
          Consumer<FavoritesViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.favoriteCourts.isEmpty) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showClearAllDialog(context, viewModel),
                tooltip: 'Clear All Favorites',
              );
            },
          ),
        ],
      ),
      body: Consumer<FavoritesViewModel>(
        builder: (context, viewModel, child) {
          final favorites = viewModel.favoriteCourts;
          
          return favorites.isEmpty
              ? _buildEmptyState()
              : _buildFavoritesGrid(favorites, context);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Favorite Courts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart icon on any court\nto add it to your favorites',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesGrid(List<Map<String, dynamic>> favorites, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final court = favorites[index];
          return FavoriteCourtCard(court: court);
        },
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, FavoritesViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites?'),
        content: const Text('This will remove all courts from your favorites list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              viewModel.clearFavorites();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All favorites cleared')),
              );
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class FavoriteCourtCard extends StatelessWidget {
  final Map<String, dynamic> court;

  const FavoriteCourtCard({Key? key, required this.court}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = court['name'] ?? 'Unknown Court';
    final vicinity = court['vicinity'] ?? 'No address available';
    final photoUrl = court['photo_url'];
    final rating = court['rating']?.toString() ?? 'No rating';

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourtDetailPage(court: court),
              ),
            );
          },
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Image - Exactly 120px
                Container(
                  height: 120,
                  width: double.infinity,
                  child: _buildCourtImage(photoUrl),
                ),
                
                // Content - Exactly 80px
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Name - Single line
                      Text(
                        name,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Address - Two lines max
                      SizedBox(
                        height: 28,
                        child: Text(
                          vicinity,
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Text(rating, style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Favorite icon in top right
        Positioned(
          top: 8,
          right: 8,
          child: Consumer<FavoritesViewModel>(
            builder: (context, viewModel, child) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 20,
                  ),
                  onPressed: () {
                    viewModel.removeFromFavorites(court);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Removed from favorites'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            viewModel.addToFavorites(court);
                          },
                        ),
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCourtImage(String? photoUrl) {
    if (photoUrl == null) {
      return Container(
        color: Colors.grey[300],
        child: Icon(Icons.sports_tennis, size: 40, color: Colors.grey[600]),
      );
    }
    
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Image.network(
        photoUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: Icon(Icons.sports_tennis, size: 40, color: Colors.grey[600]),
          );
        },
      ),
    );
  }
}