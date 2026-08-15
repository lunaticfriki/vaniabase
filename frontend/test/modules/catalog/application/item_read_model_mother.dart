import 'package:core/shared/generate_uuid_util.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';

class ItemReadModelMother {
  static ItemReadModel random({
    String? id,
    String? title,
    bool completed = false,
    String reference = '',
    List<String> tags = const ['sci-fi'],
    List<String> creator = const ['Frank Herbert'],
    String topic = 'Science Fiction',
    String publisher = 'Chilton Books',
    List<String> language = const ['en'],
    List<String> format = const ['hardcover'],
  }) {
    final now = DateTime.now();
    return ItemReadModel(
      id: id ?? generateUuidV4Util(),
      ownerId: generateUuidV4Util(),
      title: title ?? 'Dune',
      creator: creator,
      publisher: publisher,
      category: 'book',
      format: format,
      tags: tags,
      topic: topic,
      year: 1965,
      description: 'A desert planet epic.',
      language: language,
      imageUrl: 'https://picsum.photos/seed/mother/400/600',
      completed: completed,
      reference: reference,
      createdAt: now,
      updatedAt: now,
    );
  }

  static List<ItemReadModel> list(int count) {
    return List.generate(count, (index) => random(title: 'Item $index'));
  }
}
