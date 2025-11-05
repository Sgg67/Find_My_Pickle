import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewModel/favorites_viewModel.dart';
import 'view/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FavoritesViewModel(),
        ),
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