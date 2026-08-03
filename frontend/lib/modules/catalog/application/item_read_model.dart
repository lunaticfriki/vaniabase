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
