import 'package:find_my_pickle/view/home_page.dart';
import 'package:find_my_pickle/view/login.dart';
import 'package:find_my_pickle/view/search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context
  }) async {
    
    try {
      String trimmedEmail = email.trim();
      
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SearchPage()
        )
      );
      
    } on FirebaseAuthException catch(e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      } else {
        message = 'Authentication error: ${e.message}';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
    catch(e) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPage()
          )
        );
      } else {
        Fluttertoast.showToast(
          msg: 'An error occurred during signup. Please try again.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0,
        );
      }
    }
  }

  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context
  }) async {
    
    try {
      String trimmedEmail = email.trim();
      
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password
      );

      // Force navigation - login is successful despite the type casting error
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => SearchPage()
        )
      );
      
    } catch (e) {
      // If we get any error (including type casting), check if user is actually logged in
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // User is logged in despite the error, proceed to navigation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => SearchPage()
          )
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Login failed. Please check your email and password.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0,
        );
      }
    }
  }

  static Future forgotPassword({required String email}) async {
      try {
             await _firebaseAuth.sendPasswordResetEmail(email: email);
          } on FirebaseAuthException catch (err) {
             throw Exception(err.message.toString());
          } catch (err) {
             throw Exception(err.toString());
          }
      }

   static Future<void> signout({
    required BuildContext context
  }) async {
    
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => HomePage()
        )
      );
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => HomePage()
        )
      );
    }
  }
}