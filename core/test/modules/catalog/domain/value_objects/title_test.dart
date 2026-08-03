import 'package:core/modules/catalog/domain/value_objects/title.dart';
import 'package:test/test.dart';

void main() {
  group('Title', () {
    test('create accepts a valid title', () {
      final title = Title.create('The Pragmatic Programmer');

      expect(title.value, 'The Pragmatic Programmer');
    });

    test('create trims surrounding whitespace', () {
      final title = Title.create('  Dune  ');

      expect(title.value, 'Dune');
    });

    test('create throws when empty after trim', () {
      expect(() => Title.create('   '), throwsA(isA<InvalidTitleError>()));
    });

    test('create throws when longer than 200 characters', () {
      expect(
        () => Title.create('a' * 201),
        throwsA(isA<InvalidTitleError>()),
      );
    });

    test('empty returns the neutral instance', () {
      expect(Title.empty().value, '');
    });

    test('equality is structural', () {
      expect(Title.create('Dune'), equals(Title.create('Dune')));
    });
  });
}
