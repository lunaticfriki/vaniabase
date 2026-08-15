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
    required this.completed,
    required this.reference,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String title;
  final List<String> creator;
  final String publisher;
  final String category;
  final List<String> format;
  final List<String> tags;
  final String topic;
  final int year;
  final String description;
  final List<String> language;
  final String imageUrl;
  final bool completed;
  final String reference;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemReadModel copyWith({bool? completed}) {
    return ItemReadModel(
      id: id,
      ownerId: ownerId,
      title: title,
      creator: creator,
      publisher: publisher,
      category: category,
      format: format,
      tags: tags,
      topic: topic,
      year: year,
      description: description,
      language: language,
      imageUrl: imageUrl,
      completed: completed ?? this.completed,
      reference: reference,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
