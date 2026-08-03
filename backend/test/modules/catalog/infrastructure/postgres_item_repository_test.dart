import 'package:backend/modules/catalog/infrastructure/postgres_item_repository.dart';
import 'package:backend/modules/identity/infrastructure/postgres_user_repository.dart';
import 'package:backend/shared/db/database.dart';
import 'package:backend/shared/db/database_config.dart';
import 'package:core/modules/catalog/domain/criteria/item_criteria.dart';
import 'package:core/modules/catalog/domain/entities/item.dart';
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
import 'package:core/modules/catalog/domain/value_objects/tag.dart';
import 'package:core/modules/catalog/domain/value_objects/title.dart';
import 'package:core/modules/catalog/domain/value_objects/topic.dart';
import 'package:core/modules/identity/domain/entities/user.dart';
import 'package:core/modules/identity/domain/value_objects/email.dart';
import 'package:core/modules/identity/domain/value_objects/password_hash.dart';
import 'package:core/modules/identity/domain/value_objects/username.dart';
import 'package:core/shared/pagination/page_request.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

Future<User> _persistedUser(PostgresUserRepository users) async {
  final user = User.register(
    email: Email.create('jane.doe@example.com'),
    username: Username.create('jane_doe'),
    passwordHash: PasswordHash.create('hashed-value'),
  );
  await users.save(user);
  return user;
}

void main() {
  late Pool pool;
  late PostgresItemRepository repository;
  late PostgresUserRepository userRepository;

  setUpAll(() {
    pool = createConnectionPool(DatabaseConfig.fromEnvironment());
    repository = PostgresItemRepository(pool);
    userRepository = PostgresUserRepository(pool);
  });

  tearDownAll(() async {
    await pool.close();
  });

  tearDown(() async {
    await pool.execute('DELETE FROM items');
    await pool.execute('DELETE FROM users');
  });

  group('PostgresItemRepository', () {
    test('save then findById round-trips a fully populated item', () async {
      final user = await _persistedUser(userRepository);
      final item = Item.create(
        ownerId: user.id,
        title: Title.create('Dune'),
        creator: Creator.create(['Frank Herbert']),
        publisher: Publisher.create('Chilton Books'),
        category: Category.book,
        format: Format.hardcover,
        tags: ItemTags.create([Tag.create('sci-fi'), Tag.create('classic')]),
        topic: Topic.create('Science Fiction'),
        year: PublicationYear.create(1965),
        description: ItemDescription.create('A desert planet epic.'),
        language: Language.create('en'),
        imageUrl: ImageUrl.create('https://example.com/dune.jpg'),
      );

      await repository.save(item);
      final found = await repository.findById(item.id);

      expect(found, isNotNull);
      expect(found!.id, item.id);
      expect(found.ownerId, user.id);
      expect(found.title, item.title);
      expect(found.creator, item.creator);
      expect(found.tags, item.tags);
      expect(found.topic, item.topic);
      expect(found.year, item.year);
      expect(found.description, item.description);
      expect(found.language, item.language);
      expect(found.imageUrl, item.imageUrl);
    });

    test('save then findById round-trips an item with only required fields', () async {
      final user = await _persistedUser(userRepository);
      final item = Item.create(
        ownerId: user.id,
        title: Title.create('Blade Runner'),
        creator: Creator.single('Ridley Scott'),
        publisher: Publisher.create('Warner Bros.'),
        category: Category.movie,
        format: Format.bluRay,
      );

      await repository.save(item);
      final found = await repository.findById(item.id);

      expect(found, isNotNull);
      expect(found!.topic, Topic.empty());
      expect(found.year, PublicationYear.empty());
      expect(found.description, ItemDescription.empty());
      expect(found.language, Language.empty());
      expect(found.imageUrl, ImageUrl.empty());
      expect(found.tags, ItemTags.empty());
    });

    test('findById returns null when the item does not exist', () async {
      final found = await repository.findById(ItemId.generate());

      expect(found, isNull);
    });

    test('save persists an update to an existing item', () async {
      final user = await _persistedUser(userRepository);
      final item = Item.create(
        ownerId: user.id,
        title: Title.create('Dune'),
        creator: Creator.single('Frank Herbert'),
        publisher: Publisher.create('Chilton Books'),
        category: Category.book,
        format: Format.hardcover,
      );
      await repository.save(item);

      item.update(title: Title.create('Dune: New Edition'));
      await repository.save(item);

      final found = await repository.findById(item.id);
      expect(found?.title, Title.create('Dune: New Edition'));
    });

    test('delete removes the item', () async {
      final user = await _persistedUser(userRepository);
      final item = Item.create(
        ownerId: user.id,
        title: Title.create('Dune'),
        creator: Creator.single('Frank Herbert'),
        publisher: Publisher.create('Chilton Books'),
        category: Category.book,
        format: Format.hardcover,
      );
      await repository.save(item);

      await repository.delete(item.id);

      expect(await repository.findById(item.id), isNull);
    });

    test('list returns only that owner\'s items, newest first', () async {
      final owner = await _persistedUser(userRepository);
      final otherOwner = User.register(
        email: Email.create('other@example.com'),
        username: Username.create('other_user'),
        passwordHash: PasswordHash.create('hashed-value'),
      );
      await userRepository.save(otherOwner);

      final first = Item.create(
        ownerId: owner.id,
        title: Title.create('First'),
        creator: Creator.single('Author A'),
        publisher: Publisher.create('Publisher A'),
        category: Category.book,
        format: Format.hardcover,
      );
      await repository.save(first);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final second = Item.create(
        ownerId: owner.id,
        title: Title.create('Second'),
        creator: Creator.single('Author B'),
        publisher: Publisher.create('Publisher B'),
        category: Category.book,
        format: Format.paperback,
      );
      await repository.save(second);

      final othersItem = Item.create(
        ownerId: otherOwner.id,
        title: Title.create('Not Mine'),
        creator: Creator.single('Author C'),
        publisher: Publisher.create('Publisher C'),
        category: Category.book,
        format: Format.ebook,
      );
      await repository.save(othersItem);

      final results = await repository.list(
        ItemCriteria(
          ownerId: owner.id,
          pageRequest: PageRequest.create(page: 1, pageSize: 10),
        ),
      );

      expect(results.items.map((item) => item.id), [second.id, first.id]);
      expect(results.totalItems, 2);
    });

    test('list respects pagination and reports totalItems/totalPages', () async {
      final owner = await _persistedUser(userRepository);
      for (var i = 0; i < 3; i++) {
        await repository.save(
          Item.create(
            ownerId: owner.id,
            title: Title.create('Item $i'),
            creator: Creator.single('Author'),
            publisher: Publisher.create('Publisher'),
            category: Category.book,
            format: Format.hardcover,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      final page = await repository.list(
        ItemCriteria(
          ownerId: owner.id,
          pageRequest: PageRequest.create(page: 2, pageSize: 1),
        ),
      );

      expect(page.items, hasLength(1));
      expect(page.totalItems, 3);
      expect(page.totalPages, 3);
    });
  });
}
