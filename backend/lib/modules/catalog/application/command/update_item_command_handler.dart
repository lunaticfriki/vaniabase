import 'package:backend/modules/catalog/application/command/update_item_command.dart';
import 'package:core/modules/catalog/domain/errors/item_not_found_error.dart';
import 'package:core/modules/catalog/domain/repositories/item_repository.dart';
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

class UpdateItemCommandHandler {
  UpdateItemCommandHandler(this._items);

  final ItemRepository _items;

  Future<void> handle(UpdateItemCommand command) async {
    final id = ItemId.create(command.itemId);
    final requestingUserId = UserId.create(command.requestingUserId);
    final item = await _items.findById(id);
    if (item == null || !item.isOwnedBy(requestingUserId)) {
      throw ItemNotFoundError(id);
    }

    item.update(
      title: command.title == null ? null : Title.create(command.title!),
      creator: command.creator == null
          ? null
          : Creator.create(command.creator!),
      publisher: command.publisher == null
          ? null
          : Publisher.create(command.publisher!),
      category: command.category == null
          ? null
          : Category.parse(command.category!),
      format: command.format == null ? null : Format.parse(command.format!),
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
  }
}
