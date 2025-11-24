import 'package:find_my_pickle/view/signup.dart';
import 'package:find_my_pickle/view/search.dart';
import 'package:find_my_pickle/viewModel/auth_viewmodel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;

  // Animation Controller for shaking
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      authViewModel.clearError();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        leading: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact(); // Haptic on back
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.only(left: 10),
            decoration: const BoxDecoration(
                color: Color(0xffF7F7F9), shape: BoxShape.circle),
            child: const Center(
              child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutQuart,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - value)), // Slide up effect
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Hello Again',
                    style: GoogleFonts.raleway(
                        textStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 32)),
                  ),
                ),
                const SizedBox(height: 80),

                AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    // Math for shaking left and right
                    final sineValue = math.sin(4 * math.pi * _shakeController.value);
                    return Transform.translate(
                      offset: Offset(sineValue * 10, 0),
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
                      _emailAddress(),
                      const SizedBox(height: 20),
                      _password(),
                    ],
                  ),
                ),
                
                const SizedBox(height: 50),
                _signin(context),
                const SizedBox(height: 50),
                _signup(context),
                const SizedBox(height: 20),
                _forgotpassword(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailAddress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: GoogleFonts.raleway(
              textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 16)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          key: const Key('email_textfield'),
          decoration: InputDecoration(
              filled: true,
              hintText: 'sageyanoff@gmail.com',
              hintStyle: const TextStyle(
                  color: Color(0xff6A6A6A),
                  fontWeight: FontWeight.normal,
                  fontSize: 14),
              fillColor: const Color(0xffF7F7F9),
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(14))),
        )
      ],
    );
  }

  Widget _password() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: GoogleFonts.raleway(
              textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 16)),
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: _isObscure,
          controller: _passwordController,
          key: const Key('password_textfield'),
          decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xffF7F7F9),
              hintText: 'Enter your password',
              hintStyle: const TextStyle(color: Color(0xff6A6A6A)),
              prefixIcon: const Icon(Icons.lock, color: Color(0xfff28800)),
              suffixIcon: IconButton(
                key: const Key('password_visibility_icon'),
                padding: const EdgeInsets.all(0),
                iconSize: 20.0,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: _isObscure
                      ? const Icon(Icons.visibility_off, color: Colors.grey, key: ValueKey('off'))
                      : const Icon(Icons.visibility, color: Colors.black, key: ValueKey('on')),
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              ),
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(14))),
        )
      ],
    );
  }

  Widget _signin(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authViewModel.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            authViewModel.clearError();
          });
        }

        return Column(
          children: [
            if (authViewModel.isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: CircularProgressIndicator(),
              ),
            ElevatedButton(
              key: const Key('signin_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                minimumSize: const Size(double.infinity, 60),
                elevation: 0,
              ),
              onPressed: authViewModel.isLoading
                  ? null
                  : () async {
                      HapticFeedback.lightImpact();
                      
                      final success = await authViewModel.signIn(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );

                      if (success && context.mounted) {
                        HapticFeedback.mediumImpact();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchPage(),
                          ),
                        );
                      } else {
                        HapticFeedback.heavyImpact();
                        _shakeController.forward(from: 0.0);
                      }
                    },
              child: const Text(
                "Sign In",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _signup(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(children: [
            const TextSpan(
                text: "New User? ",
                style: TextStyle(
                    color: Color(0xff6A6A6A),
                    fontWeight: FontWeight.normal,
                    fontSize: 16)),
            TextSpan(
                text: "Create Account",
                style: const TextStyle(
                    color: Color(0xff1A1D1E),
                    fontWeight: FontWeight.normal,
                    fontSize: 16),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Signup(),
                      ),
                    );
                  }),
          ])),
    );
  }

  Widget _forgotpassword(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return GestureDetector(
          onTap: authViewModel.isLoading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  _showForgotPasswordDialog(context, authViewModel);
                },
          child: MouseRegion(
            cursor: authViewModel.isLoading
                ? SystemMouseCursors.forbidden
                : SystemMouseCursors.click,
            child: Container(
              padding: const EdgeInsets.all(5),
              child: Text(
                "Forgot Password?",
                style: TextStyle(
                  fontSize: 16,
                  color: authViewModel.isLoading ? Colors.grey : Colors.blue,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor:
                      authViewModel.isLoading ? Colors.grey : Colors.blue,
                  decorationThickness: 2.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showForgotPasswordDialog(
      BuildContext context, AuthViewModel authViewModel) {
    TextEditingController emailController =
        TextEditingController(text: _emailController.text);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            return AlertDialog(
              title: Text("Reset Password"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      "Enter your email address associated with the account and we will send you a password reset link"),
                  SizedBox(height: 16),
                  TextField(
                    key: const Key('forgot_password_email_textfield'),
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "Enter your email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (authViewModel.isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      authViewModel.isLoading ? null : () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  key: const Key('forgot_password_send_button'),
                  onPressed: authViewModel.isLoading
                      ? null
                      : () async {
                          HapticFeedback.lightImpact(); 
                          if (emailController.text.isNotEmpty) {
                            final success = await authViewModel.forgotPassword(
                              email: emailController.text,
                            );

                            if (success && context.mounted) {
                              Navigator.pop(context);
                              Fluttertoast.showToast(
                                msg: "Password reset email has been sent",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.SNACKBAR,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                          } else {
                            HapticFeedback.heavyImpact();
                            Fluttertoast.showToast(
                              msg: "Please enter your email address",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.SNACKBAR,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          }
                        },
                  child: Text("Reset password"),
                )
              ],
            );
          },
        );
      },
    );
  }
}