import 'package:find_my_pickle/view/home_page.dart';
import 'package:find_my_pickle/view/login.dart';
import 'package:find_my_pickle/view/signup.dart';
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

    testWidgets('Tapping Login button navigates to login', (tester) async {
      await tester.pumpWidget(createHomePage());

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsNothing);
      expect(find.byType(Login), findsOneWidget);
    });

    testWidgets('Tapping Sign Up button navigates to sign up', (tester) async {
      await tester.pumpWidget(createHomePage());

      final buttonFinder = find.text('Sign Up');
      await tester.ensureVisible(buttonFinder);
      
      await tester.pumpAndSettle();
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsNothing);
      expect(find.byType(Signup), findsOneWidget);
    });
  });
}