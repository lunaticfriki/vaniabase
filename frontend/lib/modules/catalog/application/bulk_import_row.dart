class BulkImportRow {
  const BulkImportRow({
    required this.rowNumber,
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
    required this.errors,
  });

  final int rowNumber;
  final String title;
  final List<String> creator;
  final String publisher;
  final String? category;
  final String? format;
  final List<String> tags;
  final String topic;
  final int? year;
  final String description;
  final String language;
  final String imageUrl;
  final bool completed;
  final String reference;
  final List<String> errors;

  bool get isValid => errors.isEmpty;
}
