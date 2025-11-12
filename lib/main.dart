import 'package:find_my_pickle/firebase_options.dart';
import 'package:find_my_pickle/services/authentication_service.dart';
import 'package:find_my_pickle/viewModel/auth_viewmodel.dart';
import 'package:find_my_pickle/viewModel/court_results_viewmodel.dart';
import 'package:find_my_pickle/viewModel/directions_viewmodel.dart';
import 'package:find_my_pickle/viewModel/games_viewmodel.dart';
import 'package:find_my_pickle/viewModel/home_viewmodel.dart';
import 'package:find_my_pickle/viewModel/join_game_viewmodel.dart';
import 'package:find_my_pickle/viewModel/location_viewmodel.dart';
import 'package:find_my_pickle/viewModel/search_viewmodel.dart';
import 'package:find_my_pickle/viewModel/user_profile_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewModel/favorites_viewModel.dart';
import 'view/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(AuthService())),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => FavoritesViewModel()),
        ChangeNotifierProvider(create: (_) => CourtResultsViewModel()),
        ChangeNotifierProvider(create: (_) => GameViewModel()),
        ChangeNotifierProvider(create: (_) => JoinGameViewModel()),
        ChangeNotifierProvider(create: (_) => LocationViewModel()),
        ChangeNotifierProvider(create: (_) => DirectionsViewModel()),
        ChangeNotifierProvider(create: (_) => UserProfileViewModel()),
      ],
      child: MaterialApp(
        title: "Find my Pickle",
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
        home: Builder(
          builder: (context) => const HomePage(),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
