import 'package:core/modules/catalog/domain/entities/item.dart';

class ItemReadModel {
  const ItemReadModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.creator,
    required this.publisher,
    required this.category,
    required this.format,
    required this.tags,
    required this.topic,
    required this.year,
    required this.description,
    required this.language,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemReadModel.fromDomain(Item item) {
    return ItemReadModel(
      id: item.id.value,
      ownerId: item.ownerId.value,
      title: item.title.value,
      creator: item.creator.names,
      publisher: item.publisher.value,
      category: item.category.name,
      format: item.format.name,
      tags: item.tags.value.map((tag) => tag.value).toList(),
      topic: item.topic.value,
      year: item.year.value,
      description: item.description.value,
      language: item.language.value,
      imageUrl: item.imageUrl.value,
      createdAt: item.createdAt.value,
      updatedAt: item.updatedAt.value,
    );
  }

  final String id;
  final String ownerId;
  final String title;
  final List<String> creator;
  final String publisher;
  final String category;
  final String format;
  final List<String> tags;
  final String topic;
  final int year;
  final String description;
  final String language;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
}
