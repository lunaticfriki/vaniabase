import 'package:core/modules/catalog/domain/entities/item.dart';
import 'package:core/modules/catalog/domain/errors/invalid_format_for_category_error.dart';
import 'package:core/modules/catalog/domain/search/search_term.dart';
import 'package:core/modules/catalog/domain/value_objects/category.dart';
import 'package:core/modules/catalog/domain/value_objects/creator.dart';
import 'package:core/modules/catalog/domain/value_objects/format.dart';
import 'package:core/modules/catalog/domain/value_objects/image_url.dart';
import 'package:core/modules/catalog/domain/value_objects/item_description.dart';
import 'package:core/modules/catalog/domain/value_objects/item_id.dart';
import 'package:core/modules/catalog/domain/value_objects/item_tags.dart';
import 'package:core/modules/catalog/domain/value_objects/language.dart';
import 'package:core/modules/catalog/domain/value_objects/publication_year.dart';
import 'package:core/modules/catalog/domain/value_objects/publisher.dart';
import 'package:core/modules/catalog/domain/value_objects/reference.dart';
import 'package:core/modules/catalog/domain/value_objects/title.dart';
import 'package:core/modules/catalog/domain/value_objects/topic.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:core/shared/value_objects/timestamp.dart';
import 'package:test/test.dart';

import '../../../identity/domain/entities/user_mother.dart';
import 'item_mother.dart';

void main() {
  group('Item', () {
    test('create builds a valid item when format matches category', () {
      final ownerId = UserMother.random().id;

      final item = Item.create(
        ownerId: ownerId,
        title: Title.create('Dune'),
        creator: Creator.single('Frank Herbert'),
        publisher: Publisher.create('Chilton Books'),
        category: Category.book,
        format: Format.hardcover,
      );

      expect(item.ownerId, ownerId);
      expect(item.title, Title.create('Dune'));
      expect(item.category, Category.book);
      expect(item.format, Format.hardcover);
      expect(item.id, isNot(equals(ItemId.empty())));
      expect(item.createdAt, item.updatedAt);
    });

    test('create throws when format does not match category', () {
      expect(
        () => Item.create(
          ownerId: UserMother.random().id,
          title: Title.create('Dune'),
          creator: Creator.single('Frank Herbert'),
          publisher: Publisher.create('Chilton Books'),
          category: Category.book,
          format: Format.vinyl,
        ),
        throwsA(isA<InvalidFormatForCategoryError>()),
      );
    });

    test('empty returns the neutral instance', () {
      final item = Item.empty();

      expect(item.id, ItemId.empty());
      expect(item.ownerId, UserId.empty());
      expect(item.title, Title.empty());
    });

    test('update changes only the provided fields', () {
      final item = ItemMother.book();
      final originalCreator = item.creator;
      final originalCategory = item.category;
      final newTitle = Title.create('Dune: New Edition');

      item.update(title: newTitle);

      expect(item.title, newTitle);
      expect(item.creator, originalCreator);
      expect(item.category, originalCategory);
    });

    test('update bumps updatedAt but not createdAt', () async {
      final item = ItemMother.book();
      final originalCreatedAt = item.createdAt;
      final originalUpdatedAt = item.updatedAt;

      await Future<void>.delayed(const Duration(milliseconds: 5));
      item.update(title: Title.create('New Title'));

      expect(item.createdAt, originalCreatedAt);
      expect(item.updatedAt, isNot(equals(originalUpdatedAt)));
    });

    test(
      'update throws and leaves state unchanged when the resulting '
      'format is invalid for the resulting category',
      () {
        final item = ItemMother.book();
        final originalFormat = item.format;
        final originalCategory = item.category;
        final originalUpdatedAt = item.updatedAt;

        expect(
          () => item.update(category: Category.musicAlbum),
          throwsA(isA<InvalidFormatForCategoryError>()),
        );

        expect(item.category, originalCategory);
        expect(item.format, originalFormat);
        expect(item.updatedAt, originalUpdatedAt);
      },
    );

    test('isOwnedBy is true for the owner and false for anyone else', () {
      final ownerId = UserMother.random().id;
      final item = Item.create(
        ownerId: ownerId,
        title: Title.create('Dune'),
        creator: Creator.single('Frank Herbert'),
        publisher: Publisher.create('Chilton Books'),
        category: Category.book,
        format: Format.hardcover,
      );

      expect(item.isOwnedBy(ownerId), isTrue);
      expect(item.isOwnedBy(UserId.generate()), isFalse);
    });

    test('equality does not change when mutable fields are updated', () {
      final item = ItemMother.book();
      final reference = item;

      item.update(title: Title.create('Changed Title'));

      expect(item, equals(reference));
    });

    test('two items with different ids are not equal', () {
      final first = ItemMother.book();
      final second = ItemMother.book();

      expect(first, isNot(equals(second)));
    });

    test('fromPersistence rebuilds an item with its existing identity', () {
      final id = ItemId.generate();
      final ownerId = UserMother.random().id;
      final createdAt = Timestamp.create(DateTime(2020, 1, 1));
      final updatedAt = Timestamp.create(DateTime(2021, 6, 1));

      final item = Item.fromPersistence(
        id: id,
        ownerId: ownerId,
        title: Title.create('Dune'),
        creator: Creator.single('Frank Herbert'),
        publisher: Publisher.create('Chilton Books'),
        category: Category.book,
        format: Format.hardcover,
        tags: ItemTags.empty(),
        topic: Topic.empty(),
        year: PublicationYear.empty(),
        description: ItemDescription.empty(),
        language: Language.empty(),
        reference: Reference.empty(),
        imageUrl: ImageUrl.empty(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(item.id, id);
      expect(item.ownerId, ownerId);
      expect(item.createdAt, createdAt);
      expect(item.updatedAt, updatedAt);
      expect(item.title, Title.create('Dune'));
    });

    test('fromPersistence throws for a corrupt row with mismatched '
        'category/format', () {
      expect(
        () => Item.fromPersistence(
          id: ItemId.generate(),
          ownerId: UserMother.random().id,
          title: Title.create('Dune'),
          creator: Creator.single('Frank Herbert'),
          publisher: Publisher.create('Chilton Books'),
          category: Category.book,
          format: Format.vinyl,
          tags: ItemTags.empty(),
          topic: Topic.empty(),
          year: PublicationYear.empty(),
          description: ItemDescription.empty(),
          language: Language.empty(),
          reference: Reference.empty(),
          imageUrl: ImageUrl.empty(),
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        ),
        throwsA(isA<InvalidFormatForCategoryError>()),
      );
    });

    test('matches is true when the search term is found in the title', () {
      final item = ItemMother.book();

      expect(item.matches(SearchTerm.create('Pragmatic')), isTrue);
    });

    test('matches is true when the search term is found in the creator', () {
      final item = ItemMother.book();

      expect(item.matches(SearchTerm.create('Andrew Hunt')), isTrue);
    });

    test('matches is false when the search term is found nowhere', () {
      final item = ItemMother.book();

      expect(item.matches(SearchTerm.create('nonexistent')), isFalse);
    });
  });
}
