import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:find_my_pickle/view/signup.dart';
import 'package:find_my_pickle/viewModel/auth_viewmodel.dart';
import '../stubs/auth_stub.dart' hide Signup; 

void main() {

  Widget createTestApp(AuthViewModel viewModel) {
    return ChangeNotifierProvider<AuthViewModel>.value(
      value: viewModel,
      child: MaterialApp(
        routes: {
          '/': (context) => Signup(),
          '/search': (context) => const Scaffold(body: Text('Search')),
          '/login': (context) => const Scaffold(body: Text('Login')),
        },
        initialRoute: '/',
      ),
    );
  }

  testWidgets('Signup Page renders all initial UI elements',
      (WidgetTester tester) async {
  
    final fakeAuthService = FakeAuthService();
    final authViewModel = AuthViewModel(fakeAuthService);

    await tester.pumpWidget(createTestApp(authViewModel));

    // Check Titles and Labels
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Check Inputs by Key
    expect(find.byKey(const Key('signup_email_textfield')), findsOneWidget);
    expect(find.byKey(const Key('signup_password_textfield')), findsOneWidget);

    // Check Button
    expect(find.byKey(const Key('signup_button')), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}