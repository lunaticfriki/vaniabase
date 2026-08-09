import 'package:core/modules/catalog/domain/search/item_search.dart';
import 'package:core/modules/catalog/domain/search/search_term.dart';
import 'package:test/test.dart';

import '../entities/item_mother.dart';

void main() {
  group('ItemSearch.filter', () {
    test('returns items whose title, creator, publisher, topic, reference or tags match', () {
      final book = ItemMother.book();
      final movie = ItemMother.movie();

      final results = ItemSearch.filter([book, movie], SearchTerm.create('Blade Runner'));

      expect(results, [movie]);
    });

    test('returns every item when the term is empty', () {
      final book = ItemMother.book();
      final movie = ItemMother.movie();

      final results = ItemSearch.filter([book, movie], SearchTerm.empty());

      expect(results, [book, movie]);
    });

    test('returns an empty list when nothing matches', () {
      final book = ItemMother.book();

      final results = ItemSearch.filter([book], SearchTerm.create('nonexistent'));

      expect(results, isEmpty);
    });
  });
}
