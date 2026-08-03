import 'package:core/modules/catalog/domain/errors/invalid_format_for_category_error.dart';
import 'package:core/modules/catalog/domain/services/item_format_policy.dart';
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
import 'package:core/modules/catalog/domain/value_objects/title.dart';
import 'package:core/modules/catalog/domain/value_objects/topic.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:core/shared/value_objects/timestamp.dart';

class Item {
  Item._(
    this.id,
    this.ownerId,
    this.createdAt,
    this._title,
    this._creator,
    this._publisher,
    this._category,
    this._format,
    this._tags,
    this._topic,
    this._year,
    this._description,
    this._language,
    this._imageUrl,
    this._updatedAt,
  );

  factory Item.create({
    required UserId ownerId,
    required Title title,
    required Creator creator,
    required Publisher publisher,
    required Category category,
    required Format format,
    ItemTags? tags,
    Topic? topic,
    PublicationYear? year,
    ItemDescription? description,
    Language? language,
    ImageUrl? imageUrl,
  }) {
    if (!ItemFormatPolicy.allows(category, format)) {
      throw InvalidFormatForCategoryError(category, format);
    }
    final now = Timestamp.now();
    return Item._(
      ItemId.generate(),
      ownerId,
      now,
      title,
      creator,
      publisher,
      category,
      format,
      tags ?? ItemTags.empty(),
      topic ?? Topic.empty(),
      year ?? PublicationYear.empty(),
      description ?? ItemDescription.empty(),
      language ?? Language.empty(),
      imageUrl ?? ImageUrl.empty(),
      now,
    );
  }

  factory Item.fromPersistence({
    required ItemId id,
    required UserId ownerId,
    required Title title,
    required Creator creator,
    required Publisher publisher,
    required Category category,
    required Format format,
    required ItemTags tags,
    required Topic topic,
    required PublicationYear year,
    required ItemDescription description,
    required Language language,
    required ImageUrl imageUrl,
    required Timestamp createdAt,
    required Timestamp updatedAt,
  }) {
    if (!ItemFormatPolicy.allows(category, format)) {
      throw InvalidFormatForCategoryError(category, format);
    }
    return Item._(
      id,
      ownerId,
      createdAt,
      title,
      creator,
      publisher,
      category,
      format,
      tags,
      topic,
      year,
      description,
      language,
      imageUrl,
      updatedAt,
    );
  }

  factory Item.empty() {
    final now = Timestamp.empty();
    return Item._(
      ItemId.empty(),
      UserId.empty(),
      now,
      Title.empty(),
      Creator.empty(),
      Publisher.empty(),
      Category.book,
      Format.paperback,
      ItemTags.empty(),
      Topic.empty(),
      PublicationYear.empty(),
      ItemDescription.empty(),
      Language.empty(),
      ImageUrl.empty(),
      now,
    );
  }

  final ItemId id;
  final UserId ownerId;
  final Timestamp createdAt;

  Title _title;
  Creator _creator;
  Publisher _publisher;
  Category _category;
  Format _format;
  ItemTags _tags;
  Topic _topic;
  PublicationYear _year;
  ItemDescription _description;
  Language _language;
  ImageUrl _imageUrl;
  Timestamp _updatedAt;

  Title get title => _title;
  Creator get creator => _creator;
  Publisher get publisher => _publisher;
  Category get category => _category;
  Format get format => _format;
  ItemTags get tags => _tags;
  Topic get topic => _topic;
  PublicationYear get year => _year;
  ItemDescription get description => _description;
  Language get language => _language;
  ImageUrl get imageUrl => _imageUrl;
  Timestamp get updatedAt => _updatedAt;

  void update({
    Title? title,
    Creator? creator,
    Publisher? publisher,
    Category? category,
    Format? format,
    ItemTags? tags,
    Topic? topic,
    PublicationYear? year,
    ItemDescription? description,
    Language? language,
    ImageUrl? imageUrl,
  }) {
    final nextCategory = category ?? _category;
    final nextFormat = format ?? _format;
    if (!ItemFormatPolicy.allows(nextCategory, nextFormat)) {
      throw InvalidFormatForCategoryError(nextCategory, nextFormat);
    }
    _title = title ?? _title;
    _creator = creator ?? _creator;
    _publisher = publisher ?? _publisher;
    _category = nextCategory;
    _format = nextFormat;
    _tags = tags ?? _tags;
    _topic = topic ?? _topic;
    _year = year ?? _year;
    _description = description ?? _description;
    _language = language ?? _language;
    _imageUrl = imageUrl ?? _imageUrl;
    _updatedAt = Timestamp.now();
  }

  bool isOwnedBy(UserId userId) => ownerId == userId;

  @override
  bool operator ==(Object other) => other is Item && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
