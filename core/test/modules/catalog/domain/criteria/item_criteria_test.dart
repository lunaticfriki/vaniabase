import 'package:core/modules/catalog/domain/criteria/item_criteria.dart';
import 'package:core/shared/pagination/page_request.dart';
import 'package:test/test.dart';

import '../../../identity/domain/entities/user_mother.dart';

void main() {
  group('ItemCriteria', () {
    test('equality is structural over ownerId and pageRequest', () {
      final ownerId = UserMother.random().id;

      final a = ItemCriteria(
        ownerId: ownerId,
        pageRequest: PageRequest.create(page: 2, pageSize: 10),
      );
      final b = ItemCriteria(
        ownerId: ownerId,
        pageRequest: PageRequest.create(page: 2, pageSize: 10),
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('differs when pageRequest differs', () {
      final ownerId = UserMother.random().id;

      final a = ItemCriteria(
        ownerId: ownerId,
        pageRequest: PageRequest.create(page: 1, pageSize: 10),
      );
      final b = ItemCriteria(
        ownerId: ownerId,
        pageRequest: PageRequest.create(page: 2, pageSize: 10),
      );

      expect(a == b, isFalse);
    });
  });
}
