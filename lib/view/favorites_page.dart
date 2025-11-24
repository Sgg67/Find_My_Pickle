import 'package:find_my_pickle/view/court_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewModel/favorites_viewmodel.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward(); 
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: const Icon(Icons.favorite, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 8),
            const Text('Favorite Courts'),
          ],
        ),
        backgroundColor: Colors.blue,
        actions: [
          Consumer<FavoritesViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.favoriteCourts.isEmpty) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _showClearAllDialog(context, viewModel);
                },
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
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutBack, // Bouncy curve
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value.clamp(0.0, 1.0), 
              child: child,
            ),
          );
        },
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
      ),
    );
  }

  Widget _buildFavoritesGrid(
      List<Map<String, dynamic>> favorites, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final court = favorites[index];
              final double animationStart = (index * 0.1).clamp(0.0, 1.0);
              final double animationEnd = (animationStart + 0.4).clamp(0.0, 1.0);

              final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Interval(animationStart, animationEnd,
                      curve: Curves.easeOut),
                ),
              );

              return FadeTransition(
                opacity: animation,
                child: Transform.translate(
                  offset: Offset(0, 50 * (1 - animation.value)), // Slide up 50px
                  child: FavoriteCourtCard(court: court),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, FavoritesViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites?'),
        content:
            const Text('This will remove all courts from your favorites list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.heavyImpact(); // Haptic on confirm
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

  const FavoriteCourtCard({super.key, required this.court});

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
            HapticFeedback.selectionClick(); // Haptic on card tap
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
                // Image
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Hero(
                    tag: photoUrl ?? name, 
                    child: _buildCourtImage(photoUrl),
                  ),
                ),

                // Content
                Container(
                  height: 80,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Name
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Address
                      SizedBox(
                        height: 28,
                        child: Text(
                          vicinity,
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[600]),
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
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact(); // Haptic on toggle
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
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  // ICON MORPH ANIMATION
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> anim) {
                      return ScaleTransition(scale: anim, child: child);
                    },
                    child: const Icon(
                      Icons.favorite,
                      key: ValueKey('fav'),
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCourtImage(String? photoUrl) {
    Widget imageWidget = Image.asset(
      'assets/my_pickleball_image.jpeg',
      fit: BoxFit.cover,
    );

    if (photoUrl != null) {
      imageWidget = Image.network(
        photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/court_placeholder.png',
            fit: BoxFit.cover,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: imageWidget,
    );
  }
}