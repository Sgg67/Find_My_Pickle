import 'package:find_my_pickle/view/court_details_view.dart';
import 'package:flutter/material.dart';

class CourtResultsPage extends StatelessWidget {
  final List<Map<String, dynamic>> courts;
  final String searchQuery;

  const CourtResultsPage({
    super.key,
    required this.courts,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courts near $searchQuery'),
        backgroundColor: Colors.blue,
      ),
      body: courts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
            )
          : Padding(
              padding: EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: courts.length,
                itemBuilder: (context, index) {
                  final court = courts[index];
                  return CourtCard(court: court);
                },
              ),
            ),
    );
  }
}

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
        // Navigate to court detail page when card is tapped
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
            SizedBox(
              height: 120,
              width: double.infinity,
              child: _buildCourtImage(photoUrl),
            ),
            
            // Content - Exactly 80px
            Container(
              height: 80,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Name - Single line
                  Text(
                    name,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                      Icon(Icons.star, color: Colors.amber, size: 12),
                      SizedBox(width: 2),
                      Text(rating, style: TextStyle(fontSize: 10)),
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
        color: Colors.grey[300],
        child: Icon(Icons.sports_tennis, size: 40, color: Colors.grey[600]),
      );
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
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