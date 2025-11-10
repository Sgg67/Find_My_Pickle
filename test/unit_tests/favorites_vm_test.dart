import 'package:flutter_test/flutter_test.dart';
import 'package:find_my_pickle/viewModel/favorites_viewmodel.dart';

void main() {
    group('Favorites vm tests', () {

        late FavoritesViewModel viewModel;

        final court1 = {'place_id': 'test_1', 'key': 'val1'};
        final court2 = {'place_id': 'test_2', 'key': 'val2'};
        final court1Copy = {'place_id': 'test_1', 'key': 'val1_copy'};
        
        setUp(() {
            viewModel = FavoritesViewModel();
        });

        test('Testing add', () {
            viewModel.addToFavorites(court1);

            expect(viewModel.favoriteCourts.length, 1);
            expect(viewModel.favoriteCourts, contains(court1));
        });

        test('Testing adding with same name', () {
            viewModel.addToFavorites(court1);
            viewModel.addToFavorites(court1Copy);
            
            expect(viewModel.favoriteCourts.length, 1);
        });

        test('Testing remove', () {
            viewModel.addToFavorites(court1);
            viewModel.addToFavorites(court2);
            viewModel.removeFromFavorites(court1);

            expect(viewModel.favoriteCourts.length, 1);
            expect(viewModel.favoriteCourts, contains(court2));
            expect(viewModel.favoriteCourts, isNot(contains(court1)));
        });

        test('Testing isCourtInFavorites', () {
            viewModel.addToFavorites(court1);
            expect(viewModel.isCourtInFavorites(court1), true);

            viewModel.removeFromFavorites(court1);
            expect(viewModel.isCourtInFavorites(court1), false);
        });

        test('Testing toggle', () {
            viewModel.toggleFavorite(court1);
            expect(viewModel.favoriteCourts, contains(court1));

            viewModel.toggleFavorite(court1);
            expect(viewModel.favoriteCourts, isNot(contains(court1)));
        });

        test('Testing clear', () {
            viewModel.addToFavorites(court1);
            viewModel.addToFavorites(court2);
            viewModel.clearFavorites();
            expect(viewModel.favoriteCourts, isEmpty);
        });

    });
}