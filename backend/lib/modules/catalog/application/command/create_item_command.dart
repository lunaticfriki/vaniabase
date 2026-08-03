class CreateItemCommand {
  const CreateItemCommand({
    required this.ownerId,
    required this.title,
    required this.creator,
    required this.publisher,
    required this.category,
    required this.format,
    this.tags,
    this.topic,
    this.year,
    this.description,
    this.language,
    this.imageUrl,
  });

  final String ownerId;
  final String title;
  final List<String> creator;
  final String publisher;
  final String category;
  final String format;
  final List<String>? tags;
  final String? topic;
  final int? year;
  final String? description;
  final String? language;
  final String? imageUrl;
}
