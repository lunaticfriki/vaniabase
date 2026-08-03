import 'package:core/modules/catalog/domain/value_objects/tag.dart';
import 'package:test/test.dart';

void main() {
  group('Tag', () {
    test('create trims and lowercases the value', () {
      final tag = Tag.create('  Sci-Fi  ');

      expect(tag.value, 'sci-fi');
    });

    test('create throws when empty after trim', () {
      expect(() => Tag.create('   '), throwsA(isA<InvalidTagError>()));
    });

    test('create throws when longer than 30 characters', () {
      expect(() => Tag.create('a' * 31), throwsA(isA<InvalidTagError>()));
    });

    test('equality is structural', () {
      expect(Tag.create('Sci-Fi'), equals(Tag.create('sci-fi')));
    });
  });
}
