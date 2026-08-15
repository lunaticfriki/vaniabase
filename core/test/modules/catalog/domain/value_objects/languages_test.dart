import 'package:core/modules/catalog/domain/value_objects/language.dart';
import 'package:core/modules/catalog/domain/value_objects/languages.dart';
import 'package:test/test.dart';

void main() {
  group('Languages', () {
    test('create accepts a list of languages', () {
      final languages = Languages.create([
        Language.create('en'),
        Language.create('fr'),
      ]);

      expect(languages.value, [Language.create('en'), Language.create('fr')]);
    });

    test('create dedups equal languages', () {
      final languages = Languages.create([
        Language.create('en'),
        Language.create('en'),
      ]);

      expect(languages.value, [Language.create('en')]);
    });

    test('create accepts an empty list', () {
      expect(Languages.create([]).value, <Language>[]);
    });

    test('empty returns an empty language list', () {
      expect(Languages.empty().value, <Language>[]);
    });

    test('contains checks membership', () {
      final languages = Languages.create([Language.create('en')]);

      expect(languages.contains(Language.create('en')), isTrue);
      expect(languages.contains(Language.create('fr')), isFalse);
    });

    test('equality is structural', () {
      expect(
        Languages.create([Language.create('en')]),
        equals(Languages.create([Language.create('en')])),
      );
    });
  });
}
