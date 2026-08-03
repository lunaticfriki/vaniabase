import 'package:core/modules/catalog/domain/value_objects/language.dart';
import 'package:test/test.dart';

void main() {
  group('Language', () {
    test('create accepts a valid 2-letter code', () {
      final language = Language.create('en');

      expect(language.value, 'en');
    });

    test('create lowercases the value', () {
      final language = Language.create('EN');

      expect(language.value, 'en');
    });

    test('create throws when not a 2-letter code', () {
      expect(
        () => Language.create('eng'),
        throwsA(isA<InvalidLanguageError>()),
      );
    });

    test('create throws for non-letter characters', () {
      expect(
        () => Language.create('e1'),
        throwsA(isA<InvalidLanguageError>()),
      );
    });

    test('empty returns the neutral instance', () {
      expect(Language.empty().value, '');
    });

    test('equality is structural', () {
      expect(Language.create('en'), equals(Language.create('en')));
    });
  });
}
