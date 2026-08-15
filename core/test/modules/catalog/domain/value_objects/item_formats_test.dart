import 'package:core/modules/catalog/domain/value_objects/format.dart';
import 'package:core/modules/catalog/domain/value_objects/item_formats.dart';
import 'package:test/test.dart';

void main() {
  group('ItemFormats', () {
    test('create accepts a list of formats', () {
      final formats = ItemFormats.create([Format.dvd, Format.bluRay]);

      expect(formats.value, [Format.dvd, Format.bluRay]);
    });

    test('create dedups equal formats', () {
      final formats = ItemFormats.create([Format.dvd, Format.dvd]);

      expect(formats.value, [Format.dvd]);
    });

    test('create throws when the list is empty', () {
      expect(
        () => ItemFormats.create([]),
        throwsA(isA<InvalidItemFormatsError>()),
      );
    });

    test('empty returns an empty format list', () {
      expect(ItemFormats.empty().value, <Format>[]);
    });

    test('contains checks membership', () {
      final formats = ItemFormats.create([Format.dvd]);

      expect(formats.contains(Format.dvd), isTrue);
      expect(formats.contains(Format.bluRay), isFalse);
    });

    test('equality is structural', () {
      expect(
        ItemFormats.create([Format.dvd, Format.bluRay]),
        equals(ItemFormats.create([Format.dvd, Format.bluRay])),
      );
    });
  });
}
