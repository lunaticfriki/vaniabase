import 'package:backend/modules/catalog/application/command/create_item_command.dart';
import 'package:core/modules/catalog/domain/entities/item.dart';
import 'package:core/modules/catalog/domain/repositories/item_repository.dart';
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
import 'package:core/modules/identity/domain/value_objects/user_id.dart';

class CreateItemCommandHandler {
  CreateItemCommandHandler(this._items);

  final ItemRepository _items;

  Future<String> handle(CreateItemCommand command) async {
    final item = Item.create(
      ownerId: UserId.create(command.ownerId),
      title: Title.create(command.title),
      creator: Creator.create(command.creator),
      publisher: Publisher.create(command.publisher),
      category: Category.parse(command.category),
      format: Format.parse(command.format),
      tags: command.tags == null
          ? null
          : ItemTags.create(command.tags!.map(Tag.create).toList()),
      topic: command.topic == null ? null : Topic.create(command.topic!),
      year: command.year == null
          ? null
          : PublicationYear.create(command.year!),
      description: command.description == null
          ? null
          : ItemDescription.create(command.description!),
      language: command.language == null
          ? null
          : Language.create(command.language!),
      imageUrl: command.imageUrl == null
          ? null
          : ImageUrl.create(command.imageUrl!),
    );

    await _items.save(item);
    return item.id.value;
  }
}
