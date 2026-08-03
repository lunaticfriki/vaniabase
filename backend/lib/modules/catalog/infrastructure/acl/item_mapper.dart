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
import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:core/shared/value_objects/timestamp.dart';

class ItemMapper {
  static Item toDomain(Map<String, dynamic> row) {
    final topic = row['topic'] as String;
    final year = row['year'] as int;
    final description = row['description'] as String;
    final language = row['language'] as String;
    final imageUrl = row['image_url'] as String;

    return Item.fromPersistence(
      id: ItemId.create(row['id'] as String),
      ownerId: UserId.create(row['owner_id'] as String),
      title: Title.create(row['title'] as String),
      creator: Creator.create((row['creator'] as List).cast<String>()),
      publisher: Publisher.create(row['publisher'] as String),
      category: Category.parse(row['category'] as String),
      format: Format.parse(row['format'] as String),
      tags: ItemTags.create(
        (row['tags'] as List).cast<String>().map(Tag.create).toList(),
      ),
      topic: topic.isEmpty ? Topic.empty() : Topic.create(topic),
      year: year == 0 ? PublicationYear.empty() : PublicationYear.create(year),
      description: description.isEmpty
          ? ItemDescription.empty()
          : ItemDescription.create(description),
      language: language.isEmpty ? Language.empty() : Language.create(language),
      imageUrl: imageUrl.isEmpty ? ImageUrl.empty() : ImageUrl.create(imageUrl),
      createdAt: Timestamp.create(row['created_at'] as DateTime),
      updatedAt: Timestamp.create(row['updated_at'] as DateTime),
    );
  }

  static Map<String, dynamic> toPersistence(Item item) {
    return {
      'id': item.id.value,
      'owner_id': item.ownerId.value,
      'title': item.title.value,
      'creator': item.creator.names,
      'publisher': item.publisher.value,
      'category': item.category.name,
      'format': item.format.name,
      'tags': item.tags.value.map((tag) => tag.value).toList(),
      'topic': item.topic.value,
      'year': item.year.value,
      'description': item.description.value,
      'language': item.language.value,
      'image_url': item.imageUrl.value,
      'created_at': item.createdAt.value,
      'updated_at': item.updatedAt.value,
    };
  }
}
