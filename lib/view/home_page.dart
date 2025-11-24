import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:find_my_pickle/view/login.dart';
import 'package:find_my_pickle/view/search.dart';
import 'package:find_my_pickle/view/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:custom_button_builder/custom_button_builder.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Find My 🥒',
          style: TextStyle(
            fontSize: 40.0,
            color: Colors.blue,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutExpo,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 40 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(width: 20, color: Colors.blueAccent),
                      gradient: const LinearGradient(
                        colors: [Colors.yellow, Color(0xffad9c00)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Image.asset(
                      'assets/my_pickleball_image.jpeg',
                      width: 300,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const TextBox(),
                const SizedBox(height: 30),
                const AuthenticationButton(), 
                const SizedBox(height: 20), 
                const SignUpButton(),
                const SizedBox(height: 20), 
                const ContinueAsGuestText(), 
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ContinueAsGuestText extends StatelessWidget {
  const ContinueAsGuestText({super.key});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SearchPage(),
          )
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(5),
          child: const Text(
            "Continue As Guest",
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: Colors.blue,
              decorationThickness: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}

class AuthenticationButton extends StatelessWidget {
  const AuthenticationButton({super.key});
  
  @override
  Widget build(BuildContext context) {
    return CustomButton(
      width: 300,
      backgroundColor: Colors.green,
      isThreeD: true,
      height: 60,
      borderRadius: 25,
      padding: const EdgeInsets.all(0),
      animate: true,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Login(),
          )
        );
      },
      child: const Text(
        "Login",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class SignUpButton extends StatelessWidget {
  const SignUpButton({super.key});
  
  @override
  Widget build(BuildContext context) {
    return CustomButton(
      width: 300,
      backgroundColor: Colors.blue,
      isThreeD: true,
      height: 60,
      borderRadius: 25,
      padding: const EdgeInsets.all(0),
      animate: true,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Signup(),
          )
        );
      },
      child: const Text(
        "Sign Up",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class TextBox extends StatelessWidget {
  const TextBox({super.key});
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: DefaultTextStyle(
        style: const TextStyle(
          fontSize: 30,
          fontFamily: 'Bobbers',
          color: Colors.blue,
        ),
        child: AnimatedTextKit(
          animatedTexts: [
            TyperAnimatedText("   Find a 🥒 court"),
            TyperAnimatedText("   Near you today"),
          ],
          repeatForever: true, 
          pause: const Duration(milliseconds: 1000), 
          displayFullTextOnTap: true,
          stopPauseOnTap: true, 
          onTap: () {
            HapticFeedback.selectionClick();
          },
        ),
      ),
    );
  }
}