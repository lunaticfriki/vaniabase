import 'package:frontend/modules/catalog/infrastructure/http_item_repository.dart';

abstract class ItemWriteService {
  Future<String> create({
    required String title,
    required List<String> creator,
    required String publisher,
    required String category,
    required String format,
    List<String>? tags,
    String? topic,
    int? year,
    String? description,
    String? language,
    String? imageUrl,
  });
}

class ItemWriteServiceImpl implements ItemWriteService {
  ItemWriteServiceImpl(this._repository);

  final HttpItemRepository _repository;

  @override
  Future<String> create({
    required String title,
    required List<String> creator,
    required String publisher,
    required String category,
    required String format,
    List<String>? tags,
    String? topic,
    int? year,
    String? description,
    String? language,
    String? imageUrl,
  }) => _repository.create(
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
  );
}
