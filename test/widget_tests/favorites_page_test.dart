import 'package:find_my_pickle/view/court_details_view.dart';
import 'package:find_my_pickle/view/favorites_page.dart';
import 'package:find_my_pickle/viewModel/favorites_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget createTestApp(FavoritesViewModel viewModel) {
  return ChangeNotifierProvider.value(
    value: viewModel,
    child: const MaterialApp(
      home: FavoritesPage(),
    ),
  );
}

void main() {

  final fakeCourt1 = {
    'place_id': '12345',
    'name': 'Test Court 1',
    'vicinity': '123 Test St',
    'rating': 4.5,
    'photo_url': null
  };
  
  testWidgets('displays empty state when there are no favorites',
      (tester) async {

    final viewModel = FavoritesViewModel(); 
    await tester.pumpWidget(createTestApp(viewModel));

    expect(find.text('Favorite Courts'), findsOneWidget);
    expect(find.text('No Favorite Courts'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });
  
  testWidgets('navigates to detail page when a court is tapped',
      (tester) async {

    final viewModel = FavoritesViewModel();
    viewModel.addToFavorites(fakeCourt1);
    await tester.pumpWidget(createTestApp(viewModel));

    await tester.tap(find.text('Test Court 1'));
    await tester.pumpAndSettle();

    expect(find.byType(FavoritesPage), findsNothing);
    expect(find.byType(CourtDetailPage), findsOneWidget);
  });

  testWidgets('removes a court when favorite icon is tapped', (tester) async {
    final viewModel = FavoritesViewModel();
    viewModel.addToFavorites(fakeCourt1);
    await tester.pumpWidget(createTestApp(viewModel));

    expect(find.text('Test Court 1'), findsOneWidget);

    final iconFinder = find.descendant(
      of: find.byType(FavoriteCourtCard),
      matching: find.byIcon(Icons.favorite),
    );
    await tester.tap(iconFinder);
    await tester.pumpAndSettle();

    expect(find.text('Removed from favorites'), findsOneWidget);
    expect(find.text('Test Court 1'), findsNothing);
    expect(find.text('No Favorite Courts'), findsOneWidget);
  });


  testWidgets('shows clear all dialog and clears favorites', (tester) async {
    final viewModel = FavoritesViewModel();
    viewModel.addToFavorites(fakeCourt1);
    await tester.pumpWidget(createTestApp(viewModel));
    
    expect(find.text('Test Court 1'), findsOneWidget); 

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle(); 

    expect(find.text('Clear All Favorites?'), findsOneWidget);

    await tester.tap(find.text('Clear All'));
    await tester.pumpAndSettle(); 

    expect(find.text('All favorites cleared'), findsOneWidget);
    expect(find.text('No Favorite Courts'), findsOneWidget);
  });
}