import 'package:find_my_pickle/services/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthViewModel with ChangeNotifier {
  final AuthService _authService;

  AuthViewModel(this._authService);

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSignedIn = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _isSignedIn;

  // Private method to handle loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Private method to handle errors
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear any existing errors
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Sign up method
  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await _authService.signup(
        email: email,
        password: password,
      );
      _setLoading(false);
      _isSignedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  // Sign in method
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await _authService.signin(
        email: email,
        password: password,
      );
      _setLoading(false);
      _isSignedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  // Forgot password method
  Future<bool> forgotPassword({required String email}) async {
    _setLoading(true);
    _setError(null);

    try {
      await _authService.forgotPassword(email: email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  // Sign out method
  Future<bool> signOut() async {
    _setLoading(true);
    _setError(null);

    try {
      await _authService.signout();
      _setLoading(false);
      _isSignedIn = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  // Check authentication status
  void checkAuthStatus() {
    // You might want to add logic here to check if user is already authenticated
    // This could be called during app startup
    _isSignedIn = _authService.isUserLoggedIn(); // You'll need to add this method to AuthService
    notifyListeners();
  }

  bool get isGuestUser {
  final user = FirebaseAuth.instance.currentUser;
  return user == null || user.isAnonymous;
}
}