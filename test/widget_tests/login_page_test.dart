import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:find_my_pickle/view/login.dart';
import 'package:find_my_pickle/viewModel/auth_viewmodel.dart';
import '../stubs/auth_stub.dart';

void main() {
  Widget createTestApp(AuthViewModel viewModel) {
    return ChangeNotifierProvider<AuthViewModel>.value(
      value: viewModel,
      child: MaterialApp(
        routes: {
          '/': (context) => Login(),
          '/search': (context) => SearchPage(),
          '/signup': (context) => Signup(),
        },
        initialRoute: '/',
      ),
    );
  }

  testWidgets('Login Page renders all initial UI elements',
      (WidgetTester tester) async {
    
    final fakeAuthService = FakeAuthService();
    
    final authViewModel = AuthViewModel(fakeAuthService);

    await tester.pumpWidget(createTestApp(authViewModel));
    
    expect(find.text('Hello Again'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.byKey(const Key('email_textfield')), findsOneWidget);
    
    expect(find.text('Password'), findsOneWidget);
    expect(find.byKey(const Key('password_textfield')), findsOneWidget);
    
    expect(find.byKey(const Key('signin_button')), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
  });
}