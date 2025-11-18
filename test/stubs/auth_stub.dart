import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:find_my_pickle/services/authentication_service.dart';

class FakeAuthService implements AuthService {
  @override
  Future<void> signup({required String email, required String password}) async {
    return; 
  }

  @override
  Future<void> signin({required String email, required String password}) async {
    return; 
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    return; 
  }

  @override
  Future<void> signout() async {
    return;
  }

  @override
  bool isUserLoggedIn() {
    return false;
  }

  @override
  Stream<User?> get authStateChanges => throw UnimplementedError();

  @override
  User? get currentUser => throw UnimplementedError();
}

// Stub for SearchPage
class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Search Page')));
  }
}

// Stub for Signup
class Signup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Signup Page')));
  }
}