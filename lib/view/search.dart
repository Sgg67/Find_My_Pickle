import 'package:find_my_pickle/view/court_results_by_location.dart';
import 'package:find_my_pickle/view/court_results_page.dart';
import 'package:find_my_pickle/viewModel/search_viewmodel.dart';
import 'package:find_my_pickle/view/favorites_page.dart'; // Add this import
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SearchViewModel viewModel = SearchViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find a court near you"),
        backgroundColor: Colors.blue,
        actions: [
          // Favorites button
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesPage(),
                ),
              );
            },
            icon: const Icon(Icons.favorite),
            tooltip: 'View Favorites',
          ),
          // Search button
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchBar(viewModel: viewModel),
              );
            },
            icon: const Icon(Icons.search),
          )
        ]
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              "Tap the search icon to find courts",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              "Enter a city and state to discover pickleball courts nearby",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            SizedBox(height: 32),
            // Optional: Add a direct button to favorites
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesPage(),
                  ),
                );
              },
              icon: Icon(Icons.favorite, color: Colors.red),
              label: Text(
                "View Favorite Courts",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CourtResultsByLocation(),
                  ),
                );
              },
              icon: Padding(
                padding: const EdgeInsets.only(top: 20.0),
              ),
              label: Text(
                "Find courts near you",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomSearchBar extends SearchDelegate {
  final SearchViewModel viewModel;
  bool _isSearching = false;

  CustomSearchBar({required this.viewModel});
  
  @override 
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override 
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override 
  Widget buildResults(BuildContext context) {
    // Only start search if not already searching
    if (!_isSearching) {
      _isSearching = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(context, query);
      });
    }
     
    return _buildLoadingState(query);
  }
  
  Future<void> _performSearch(BuildContext context, String query) async {
    try {
      print('Starting search for: $query');
      await viewModel.searchCourts(query);
      print('Search completed. Courts found: ${viewModel.courts.length}');
      
      // Reset searching flag
      _isSearching = false;
      
      // Close search bar and navigate
      if (!context.mounted) return;
      close(context, null);
      
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourtResultsPage(
            courts: viewModel.courts,
            searchQuery: query,
          ),
        ),
      );
      
    } catch (e) {
      print('Search error: $e');
      _isSearching = false; // Reset flag on error
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching: $e')),
      );
      close(context, null);
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = viewModel.getSearchSuggestions(query);

    if (suggestions.isEmpty) {
      return _buildInstructionText();
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: Icon(Icons.history),
          title: Text(suggestion),
          onTap: () {
            query = suggestion;
            showResults(context);
          },
        );
      },
    );
  }

  Widget _buildLoadingState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Searching for courts in $query...',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionText() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Enter a city and State\n(e.g., "Pittsburgh PA")',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  void close(BuildContext context, result) {
    _isSearching = false; // Reset flag when closing
    super.close(context, result);
  }
}