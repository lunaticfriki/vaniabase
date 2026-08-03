class UpdateItemCommand {
  const UpdateItemCommand({
    required this.itemId,
    required this.requestingUserId,
    this.title,
    this.creator,
    this.publisher,
    this.category,
    this.format,
    this.tags,
    this.topic,
    this.year,
    this.description,
    this.language,
    this.imageUrl,
  });

  final String itemId;
  final String requestingUserId;
  final String? title;
  final List<String>? creator;
  final String? publisher;
  final String? category;
  final String? format;
  final List<String>? tags;
  final String? topic;
  final int? year;
  final String? description;
  final String? language;
  final String? imageUrl;
}
