import 'package:core/shared/generate_uuid_util.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';

class ItemReadModelMother {
  static ItemReadModel random({String? id, String? title}) {
    final now = DateTime.now();
    return ItemReadModel(
      id: id ?? generateUuidV4Util(),
      ownerId: generateUuidV4Util(),
      title: title ?? 'Dune',
      creator: const ['Frank Herbert'],
      publisher: 'Chilton Books',
      category: 'book',
      format: 'hardcover',
      tags: const ['sci-fi'],
      topic: 'Science Fiction',
      year: 1965,
      description: 'A desert planet epic.',
      language: 'en',
      imageUrl: 'https://picsum.photos/seed/mother/400/600',
      createdAt: now,
      updatedAt: now,
    );
  }

  static List<ItemReadModel> list(int count) {
    return List.generate(count, (index) => random(title: 'Item $index'));
  }
}
