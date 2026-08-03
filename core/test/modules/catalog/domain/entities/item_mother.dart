import 'package:core/modules/catalog/domain/entities/item.dart';
import 'package:core/modules/catalog/domain/value_objects/category.dart';
import 'package:core/modules/catalog/domain/value_objects/creator.dart';
import 'package:core/modules/catalog/domain/value_objects/format.dart';
import 'package:core/modules/catalog/domain/value_objects/image_url.dart';
import 'package:core/modules/catalog/domain/value_objects/item_description.dart';
import 'package:core/modules/catalog/domain/value_objects/item_tags.dart';
import 'package:core/modules/catalog/domain/value_objects/language.dart';
import 'package:core/modules/catalog/domain/value_objects/publication_year.dart';
import 'package:core/modules/catalog/domain/value_objects/publisher.dart';
import 'package:core/modules/catalog/domain/value_objects/tag.dart';
import 'package:core/modules/catalog/domain/value_objects/title.dart';
import 'package:core/modules/catalog/domain/value_objects/topic.dart';

import '../../../identity/domain/entities/user_mother.dart';

class ItemMother {
  static Item random() => book();

  static Item empty() => Item.empty();

  static Item book() => Item.create(
    ownerId: UserMother.random().id,
    title: Title.create('The Pragmatic Programmer'),
    creator: Creator.create(['David Thomas', 'Andrew Hunt']),
    publisher: Publisher.create('Addison-Wesley'),
    category: Category.book,
    format: Format.paperback,
    tags: ItemTags.create([Tag.create('programming'), Tag.create('classic')]),
    topic: Topic.create('Software Engineering'),
    year: PublicationYear.create(1999),
    description: ItemDescription.create(
      'A guide to pragmatic software development.',
    ),
    language: Language.create('en'),
    imageUrl: ImageUrl.create(
      'https://example.com/pragmatic-programmer.jpg',
    ),
  );

  static Item movie() => Item.create(
    ownerId: UserMother.random().id,
    title: Title.create('Blade Runner'),
    creator: Creator.single('Ridley Scott'),
    publisher: Publisher.create('Warner Bros.'),
    category: Category.movie,
    format: Format.bluRay,
    year: PublicationYear.create(1982),
  );

  static Item videogame() => Item.create(
    ownerId: UserMother.random().id,
    title: Title.create('Chrono Trigger'),
    creator: Creator.single('Square'),
    publisher: Publisher.create('Square'),
    category: Category.videogame,
    format: Format.cartridge,
    year: PublicationYear.create(1995),
  );

  static Item musicAlbum() => Item.create(
    ownerId: UserMother.random().id,
    title: Title.create('Kind of Blue'),
    creator: Creator.single('Miles Davis'),
    publisher: Publisher.create('Columbia'),
    category: Category.musicAlbum,
    format: Format.vinyl,
    year: PublicationYear.create(1959),
  );
}
