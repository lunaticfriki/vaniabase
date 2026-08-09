import 'package:core/modules/catalog/domain/search/search_term.dart';
import 'package:test/test.dart';

void main() {
  group('SearchTerm', () {
    test('create accepts a valid term', () {
      final term = SearchTerm.create('Dune');

      expect(term.value, 'Dune');
    });

    test('create trims surrounding whitespace', () {
      final term = SearchTerm.create('  Dune  ');

      expect(term.value, 'Dune');
    });

    test('create throws when empty after trim', () {
      expect(() => SearchTerm.create('   '), throwsA(isA<InvalidSearchTermError>()));
    });

    test('create throws when longer than 100 characters', () {
      expect(() => SearchTerm.create('a' * 101), throwsA(isA<InvalidSearchTermError>()));
    });

    test('empty returns the neutral instance', () {
      expect(SearchTerm.empty().value, '');
      expect(SearchTerm.empty().isEmpty, isTrue);
    });

    test('matchesAny is true when the empty term is given', () {
      expect(SearchTerm.empty().matchesAny(['anything']), isTrue);
      expect(SearchTerm.empty().matchesAny([]), isTrue);
    });

    test('matchesAny is case-insensitive and matches a substring', () {
      final term = SearchTerm.create('dune');

      expect(term.matchesAny(['The Dune Chronicles']), isTrue);
    });

    test('matchesAny is true if any candidate matches', () {
      final term = SearchTerm.create('herbert');

      expect(term.matchesAny(['Dune', 'Frank Herbert']), isTrue);
    });

    test('matchesAny is false when no candidate matches', () {
      final term = SearchTerm.create('asimov');

      expect(term.matchesAny(['Dune', 'Frank Herbert']), isFalse);
    });

    test('equality is structural', () {
      expect(SearchTerm.create('Dune'), equals(SearchTerm.create('Dune')));
    });
  });
}
