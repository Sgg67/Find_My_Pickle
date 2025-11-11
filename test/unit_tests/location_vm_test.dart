import 'package:flutter_test/flutter_test.dart';
import 'package:find_my_pickle/viewModel/search_viewmodel.dart';
void main() {
  group('Search view model unit test', () {
    late SearchViewModel viewModel;

    setUp(() {
      viewModel = SearchViewModel();
    });

    test('getSearchSuggestions returns all history when query is empty', () {
      viewModel.searchHistory = ['New York', 'London', 'Tokyo'];
      final suggestions = viewModel.getSearchSuggestions('');
      
      expect(suggestions, ['Tokyo', 'London', 'New York']);
    });

    test('getSearchSuggestions returns filtered history', () {
      viewModel.searchHistory = ['New York', 'Newark', 'London'];
      final suggestions = viewModel.getSearchSuggestions('new');
      
      expect(suggestions, ['New York', 'Newark']);
    });

    test('clearCourts should empty the courts list', () {
      viewModel.courts = [{'name': 'Test Court'}];
      expect(viewModel.courtCount, 1);
      
      viewModel.clearCourts();

      expect(viewModel.courts, isEmpty);
      expect(viewModel.courtCount, 0);
    });
  });
}