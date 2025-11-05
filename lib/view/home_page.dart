import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:find_my_pickle/view/search.dart';
import 'package:flutter/material.dart';
import 'package:custom_button_builder/custom_button_builder.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(40), // ← FIXED: EdgeInsets.all instead of EdgeInsetsGeometry.all
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(width: 20, color: Colors.blueAccent),
                  gradient: LinearGradient(
                    colors: [Colors.yellow, Color(0xffad9c00)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                ),
                child: Image.network(
                  'https://thvnext.bing.com/th/id/OIP.YBEoxUo1RwxUsZg3mODK8AHaHa?w=170&h=180&c=7&r=0&o=7&cb=12&dpr=1.3&pid=1.7&rm=3&ucfimg=1',
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                )
              )),
            const TextBox(),
            const ButtonWithText(),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          'Find My 🥒',
          style: TextStyle(
            fontSize: 40.0,
            color: Colors.blue,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: true,
      ),
    );
  }
}

class ButtonWithText extends StatelessWidget {
  const ButtonWithText({super.key});
  
  @override
  Widget build(BuildContext context) {
    return CustomButton(
      width: 300,
      backgroundColor: Colors.blue,
      isThreeD: true,
      height: 50,
      borderRadius: 25,
      animate: true,
      margin: const EdgeInsets.all(80),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SearchPage(),
          )
        );
      },
      child: Text("Continue As Guest"),
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
        )
      ),
    );
  }
}