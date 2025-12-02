import 'package:find_my_pickle/view/court_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CourtResultsPage extends StatefulWidget {
  final List<Map<String, dynamic>> courts;
  final String searchQuery;

  const CourtResultsPage({
    super.key,
    required this.courts,
    required this.searchQuery,
  });

  @override
  State<CourtResultsPage> createState() => _CourtResultsPageState();
}

class _CourtResultsPageState extends State<CourtResultsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize controller for staggered list animation
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
        title: Text('Courts near ${widget.searchQuery}'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.lightImpact(); // Haptic on back
            Navigator.pop(context);
          },
        ),
      ),
      body: widget.courts.isEmpty
          ? _buildEmptyState()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: widget.courts.length,
                    itemBuilder: (context, index) {
                      final court = widget.courts[index];

                      final double animationStart =
                          (index * 0.1).clamp(0.0, 1.0);
                      final double animationEnd =
                          (animationStart + 0.4).clamp(0.0, 1.0);

                      final Animation<double> animation =
                          Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Interval(animationStart, animationEnd,
                              curve: Curves.easeOut),
                        ),
                      );

                      return FadeTransition(
                        opacity: animation,
                        child: Transform.translate(
                          offset: Offset(0, 50 * (1 - animation.value)),
                          child: CourtCard(court: court),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value, 
            child: Opacity(
              opacity: value.clamp(0.0, 1.0), 
              child: child
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.sports_tennis, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No courts found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Try searching a different location',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// court card in the court list
class CourtCard extends StatelessWidget {
  final Map<String, dynamic> court;

  const CourtCard({super.key, required this.court});

  @override
  Widget build(BuildContext context) {
    final name = court['name'] ?? 'Unknown Court';
    final vicinity = court['vicinity'] ?? 'No address available';
    final photoUrl = court['photo_url'];
    final rating = court['rating']?.toString() ?? 'No rating';

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
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
            // Image Section
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Hero(
                tag: photoUrl ?? name,
                child: _buildCourtImage(photoUrl),
              ),
            ),
            
            // Details Section
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 28,
                    child: Text(
                      vicinity,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
    );
  }

  Widget _buildCourtImage(String? photoUrl) {
    if (photoUrl == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
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
          return const Center(child: CircularProgressIndicator());
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