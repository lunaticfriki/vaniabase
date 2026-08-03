import 'package:core/modules/catalog/domain/value_objects/item_description.dart';
import 'package:test/test.dart';

void main() {
  group('ItemDescription', () {
    test('create accepts a valid description', () {
      final description = ItemDescription.create(
        'A guide to pragmatic development.',
      );

      expect(description.value, 'A guide to pragmatic development.');
    });

    test('create trims surrounding whitespace', () {
      final description = ItemDescription.create('  Some text  ');

      expect(description.value, 'Some text');
    });

    test('create throws when empty after trim', () {
      expect(
        () => ItemDescription.create('   '),
        throwsA(isA<InvalidItemDescriptionError>()),
      );
    });

    test('create throws when longer than 2000 characters', () {
      expect(
        () => ItemDescription.create('a' * 2001),
        throwsA(isA<InvalidItemDescriptionError>()),
      );
    });

    test('empty returns the neutral instance', () {
      expect(ItemDescription.empty().value, '');
    });

    test('equality is structural', () {
      expect(
        ItemDescription.create('Some text'),
        equals(ItemDescription.create('Some text')),
      );
    });
  });
}
