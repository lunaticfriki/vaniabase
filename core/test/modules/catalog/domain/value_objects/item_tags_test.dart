import 'package:core/modules/catalog/domain/value_objects/item_tags.dart';
import 'package:core/modules/catalog/domain/value_objects/tag.dart';
import 'package:test/test.dart';

void main() {
  group('ItemTags', () {
    test('create accepts a list of tags', () {
      final tags = ItemTags.create([Tag.create('sci-fi'), Tag.create('classic')]);

      expect(tags.value, [Tag.create('sci-fi'), Tag.create('classic')]);
    });

    test('create dedups equal tags', () {
      final tags = ItemTags.create([Tag.create('sci-fi'), Tag.create('sci-fi')]);

      expect(tags.value, [Tag.create('sci-fi')]);
    });

    test('create throws when there are more than 10 tags', () {
      final elevenTags = List.generate(11, (i) => Tag.create('tag$i'));

      expect(
        () => ItemTags.create(elevenTags),
        throwsA(isA<InvalidItemTagsError>()),
      );
    });

    test('empty returns an empty tag list', () {
      expect(ItemTags.empty().value, <Tag>[]);
    });

    test('count reflects the number of tags', () {
      final tags = ItemTags.create([Tag.create('sci-fi'), Tag.create('classic')]);

      expect(tags.count, 2);
    });

    test('contains checks membership', () {
      final tags = ItemTags.create([Tag.create('sci-fi')]);

      expect(tags.contains(Tag.create('sci-fi')), isTrue);
      expect(tags.contains(Tag.create('classic')), isFalse);
    });

    test('equality is structural', () {
      expect(
        ItemTags.create([Tag.create('sci-fi')]),
        equals(ItemTags.create([Tag.create('sci-fi')])),
      );
    });
  });
}
