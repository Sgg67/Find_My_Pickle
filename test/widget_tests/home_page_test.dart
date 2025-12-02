import 'package:find_my_pickle/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget createHomePage() {
  return const MaterialApp(
    home: HomePage(),
  );
}

void main() {
  group('Home page widget test)', () {
    
    testWidgets('HomePage renders all components correctly', (tester) async {
      await tester.pumpWidget(createHomePage());
      await tester.pump(Duration.zero);

      //Verify all components are on screen
      expect(find.text('Find My 🥒'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Continue As Guest'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
    
  });
}