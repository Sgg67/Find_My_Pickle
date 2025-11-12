import 'package:find_my_pickle/services/authentication_service.dart';
import 'package:find_my_pickle/view/court_results_by_location.dart';
import 'package:find_my_pickle/view/court_results_page.dart';
import 'package:find_my_pickle/view/home_page.dart';
import 'package:find_my_pickle/viewModel/auth_viewmodel.dart'; // Add AuthViewModel import
import 'package:find_my_pickle/viewModel/search_viewmodel.dart';
import 'package:find_my_pickle/view/favorites_page.dart';
import 'package:find_my_pickle/view/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  Uint8List? profileImage;
  bool isLoadingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  // Helper method to check if user is a guest
  bool get _isGuestUser {
    return currentUser?.isAnonymous ?? true;
  }

  Future<void> _loadProfilePicture() async {
    try {
      if (currentUser == null || _isGuestUser) return;
      
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child("users/${currentUser!.uid}/profile.jpg");
      final imageBytes = await imageRef.getData();
      
      if (imageBytes != null && mounted) {
        setState(() => profileImage = imageBytes);
      }
    } catch (e) {
      print("Profile picture cannot be found: $e");
    }
  }

  Future<void> _onProfilePictureTap() async {
    if (_isGuestUser) {
      _showGuestUserError();
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => isLoadingProfile = true);

    final PermissionStatus status = await Permission.photos.request();
    
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo library permission is required to change profile picture.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => isLoadingProfile = false);
      return;
    }
    
    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
      setState(() => isLoadingProfile = false);
      return;
    }

    try {
      final imageBytes = await image.readAsBytes();
      
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child("users/${currentUser!.uid}/profile.jpg"); 
      await imageRef.putData(imageBytes);
      
      if (mounted) {
        setState(() {
          profileImage = imageBytes;
          isLoadingProfile = false;
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated!')),
      );
    } catch (e) {
      print("Error uploading image: $e");
      if (mounted) {
        setState(() => isLoadingProfile = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Photo library access is permanently denied. Please enable it in app settings to change your profile picture.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('SETTINGS'),
          ),
        ],
      ),
    );
  }

  void _showGuestUserError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Guest users cannot update profile photos. Please sign up for a full account.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange[800],
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'SIGN UP',
          textColor: Colors.white,
          onPressed: _navigateToSignUp,
        ),
      ),
    );
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Signup(),
      ),
    );
  }

  // Updated logout method using AuthViewModel
  Future<void> _signOut() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authViewModel.signOut();
    
    if (success && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find a court"),
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
          // Profile Picture
          GestureDetector(
            onTap: _onProfilePictureTap,
            child: Container(
              margin: const EdgeInsets.all(8),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _isGuestUser ? Colors.grey[400] : Colors.blue[100],
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white, 
                  width: 2,
                ),
                image: profileImage != null
                    ? DecorationImage(
                        fit: BoxFit.cover,
                        image: MemoryImage(profileImage!),
                      )
                    : null,
              ),
              child: isLoadingProfile
                  ? const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : profileImage == null
                      ? Center(
                          child: Icon(
                            _isGuestUser ? Icons.person_outline : Icons.person,
                            color: _isGuestUser ? Colors.white : Colors.black38,
                            size: 20,
                          ),
                        )
                      : null,
            ),
          ),
          // Search button - UPDATED: Use Provider to get SearchViewModel
          IconButton(
            onPressed: () {
              final searchViewModel = Provider.of<SearchViewModel>(context, listen: false);
              showSearch(
                context: context,
                delegate: CustomSearchBar(searchViewModel: searchViewModel),
              );
            },
            icon: const Icon(Icons.search),
          ),
          // Logout button - UPDATED: Use AuthViewModel
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Tap the search icon to find courts",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              "Enter a city and state to discover pickleball courts nearby",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesPage(),
                  ),
                );
              },
              icon: const Icon(Icons.favorite, color: Colors.red),
              label: const Text(
                "View Favorite Courts",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CourtResultsByLocation(),
                  ),
                );
              },
              icon: const Icon(Icons.location_on, color: Colors.white),
              label: const Text(
                "Find courts near you",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomSearchBar extends SearchDelegate {
  final SearchViewModel searchViewModel;
  bool _isSearching = false;

  CustomSearchBar({required this.searchViewModel});
  
  @override 
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override 
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override 
  Widget buildResults(BuildContext context) {
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
      await searchViewModel.searchCourts(query);
      
      _isSearching = false;
      
      if (!context.mounted) return;
      close(context, null);
      
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourtResultsPage(
            courts: searchViewModel.courts,
            searchQuery: query,
          ),
        ),
      );
      
    } catch (e) {
      print('Search error: $e');
      _isSearching = false;
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching: $e')),
      );
      close(context, null);
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = searchViewModel.getSearchSuggestions(query);

    if (suggestions.isEmpty) {
      return _buildInstructionText();
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.history),
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
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Searching for courts in $query...',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
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
          const SizedBox(height: 16),
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
    _isSearching = false;
    super.close(context, result);
  }
}