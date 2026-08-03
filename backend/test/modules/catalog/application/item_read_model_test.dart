import 'package:backend/modules/catalog/application/item_read_model.dart';
import 'package:test/test.dart';

import '../../../../../core/test/modules/catalog/domain/entities/item_mother.dart';

void main() {
  group('ItemReadModel', () {
    test('fromDomain flattens an item into primitives', () {
      final item = ItemMother.book();

      final readModel = ItemReadModel.fromDomain(item);

      expect(readModel.id, item.id.value);
      expect(readModel.ownerId, item.ownerId.value);
      expect(readModel.title, item.title.value);
      expect(readModel.creator, item.creator.names);
      expect(readModel.publisher, item.publisher.value);
      expect(readModel.category, item.category.name);
      expect(readModel.format, item.format.name);
      expect(readModel.tags, item.tags.value.map((tag) => tag.value).toList());
      expect(readModel.topic, item.topic.value);
      expect(readModel.year, item.year.value);
      expect(readModel.description, item.description.value);
      expect(readModel.language, item.language.value);
      expect(readModel.imageUrl, item.imageUrl.value);
      expect(readModel.createdAt, item.createdAt.value);
      expect(readModel.updatedAt, item.updatedAt.value);
    });
  });
}
