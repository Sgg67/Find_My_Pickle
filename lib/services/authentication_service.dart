import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Check if user is logged in
  bool isUserLoggedIn() => _auth.currentUser != null;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signup({
    required String email,
    required String password,
  }) async {
    // Add validation for empty fields
    if (email.isEmpty || password.isEmpty) {
      throw Exception('You must enter an email and password to sign up');
    }

    String trimmedEmail = email.trim();

    // Additional validation for empty after trim
    if (trimmedEmail.isEmpty) {
      throw Exception('Please enter a valid email address');
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password
      );
    
    } on FirebaseAuthException catch(e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else {
        message = 'Authentication error: ${e.message}';
      }
      throw Exception(message);
    } catch(e) {
      throw Exception('An error occurred during signup. Please try again.');
    }
  }

  Future<void> signin({
    required String email,
    required String password,
  }) async {
    try {
      String trimmedEmail = email.trim();
      
      await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password
      );
      
    } catch (e) {
      throw Exception('Login failed. Please check your email and password.');
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (err) {
      throw Exception(err.message.toString());
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error signing out: ${e.toString()}');
    }
  }
}