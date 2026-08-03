import 'package:core/modules/catalog/domain/value_objects/creator.dart';
import 'package:test/test.dart';

void main() {
  group('Creator', () {
    test('create accepts a list of names', () {
      final creator = Creator.create(['David Thomas', 'Andrew Hunt']);

      expect(creator.names, ['David Thomas', 'Andrew Hunt']);
    });

    test('create trims each name', () {
      final creator = Creator.create(['  Frank Herbert  ']);

      expect(creator.names, ['Frank Herbert']);
    });

    test('create removes empty names', () {
      final creator = Creator.create(['Frank Herbert', '   ']);

      expect(creator.names, ['Frank Herbert']);
    });

    test('create dedups case-insensitively', () {
      final creator = Creator.create(['Frank Herbert', 'frank herbert']);

      expect(creator.names, ['Frank Herbert']);
    });

    test('create throws when the resulting list is empty', () {
      expect(
        () => Creator.create(['   ', '']),
        throwsA(isA<InvalidCreatorError>()),
      );
    });

    test('create throws when a name exceeds 100 characters', () {
      expect(
        () => Creator.create(['a' * 101]),
        throwsA(isA<InvalidCreatorError>()),
      );
    });

    test('single is a convenience factory for one name', () {
      final creator = Creator.single('Frank Herbert');

      expect(creator.names, ['Frank Herbert']);
    });

    test('empty returns the neutral instance', () {
      expect(Creator.empty().names, <String>[]);
    });

    test('displayName joins names with a comma', () {
      final creator = Creator.create(['David Thomas', 'Andrew Hunt']);

      expect(creator.displayName, 'David Thomas, Andrew Hunt');
    });

    test('equality is structural', () {
      expect(
        Creator.create(['Frank Herbert']),
        equals(Creator.create(['Frank Herbert'])),
      );
    });
  });
}
