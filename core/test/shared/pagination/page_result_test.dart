import 'package:core/shared/pagination/page_result.dart';
import 'package:test/test.dart';

void main() {
  group('PageResult', () {
    test('computes totalPages by ceiling totalItems over pageSize', () {
      final result = PageResult<int>(
          items: const [1, 2], page: 1, pageSize: 10, totalItems: 25);

      expect(result.totalPages, 3);
    });

    test('totalPages is 0 when there are no items', () {
      final result = PageResult<int>.empty();

      expect(result.totalPages, 0);
    });

    test('hasNextPage is true while page is below totalPages', () {
      final result = PageResult<int>(
          items: const [], page: 1, pageSize: 10, totalItems: 25);

      expect(result.hasNextPage, isTrue);
    });

    test('hasNextPage is false on the last page', () {
      final result = PageResult<int>(
          items: const [], page: 3, pageSize: 10, totalItems: 25);

      expect(result.hasNextPage, isFalse);
    });

    test('hasPreviousPage is false on the first page', () {
      final result = PageResult<int>(
          items: const [], page: 1, pageSize: 10, totalItems: 25);

      expect(result.hasPreviousPage, isFalse);
    });

    test('hasPreviousPage is true past the first page', () {
      final result = PageResult<int>(
          items: const [], page: 2, pageSize: 10, totalItems: 25);

      expect(result.hasPreviousPage, isTrue);
    });

    test('map transforms items while keeping pagination metadata', () {
      final result = PageResult<int>(
          items: const [1, 2, 3], page: 2, pageSize: 3, totalItems: 9);

      final mapped = result.map((item) => 'item-$item');

      expect(mapped.items, ['item-1', 'item-2', 'item-3']);
      expect(mapped.page, 2);
      expect(mapped.pageSize, 3);
      expect(mapped.totalItems, 9);
    });
  });
}
