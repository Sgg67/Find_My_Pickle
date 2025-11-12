import 'package:find_my_pickle/firebase_options.dart';
import 'package:find_my_pickle/viewModel/games_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewModel/favorites_viewModel.dart';
import 'view/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Fix: Put both providers in the same list, don't nest them
        ChangeNotifierProvider(create: (_) => FavoritesViewModel()),
        ChangeNotifierProvider(create: (_) => GameViewModel()), // Make sure this matches your class name
      ],
      child: MaterialApp(
        title: "Find my Pickle",
        theme: ThemeData(
          useMaterial3: true, 
          colorSchemeSeed: Colors.blue,
        ),
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}