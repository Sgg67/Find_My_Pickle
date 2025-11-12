import 'package:flutter/foundation.dart';

class UserProfileViewModel with ChangeNotifier {
  String? _userName;
  String? _userEmail;
  bool _isLoading = false;
  String? _errorMessage;

  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Load user profile data
      await Future.delayed(Duration(milliseconds: 600));
      _userName = "User Name"; // Replace with actual data
      _userEmail = "user@example.com"; // Replace with actual data
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Update profile logic
      await Future.delayed(Duration(milliseconds: 800));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}