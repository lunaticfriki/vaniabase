import 'package:core/shared/pagination/page_request.dart';
import 'package:test/test.dart';

void main() {
  group('PageRequest', () {
    test('create defaults to page 1 and the default page size', () {
      final pageRequest = PageRequest.create();

      expect(pageRequest.page, 1);
      expect(pageRequest.pageSize, PageRequest.defaultPageSize);
    });

    test('computes limit and offset from page and pageSize', () {
      final pageRequest = PageRequest.create(page: 3, pageSize: 10);

      expect(pageRequest.limit, 10);
      expect(pageRequest.offset, 20);
    });

    test('rejects a page below 1', () {
      expect(() => PageRequest.create(page: 0), throwsA(isA<InvalidPageRequestError>()));
    });

    test('rejects a pageSize outside 1..maxPageSize', () {
      expect(() => PageRequest.create(pageSize: 0), throwsA(isA<InvalidPageRequestError>()));
      expect(
        () => PageRequest.create(pageSize: PageRequest.maxPageSize + 1),
        throwsA(isA<InvalidPageRequestError>()),
      );
    });

    test('next advances the page and keeps the pageSize', () {
      final pageRequest = PageRequest.create(page: 1, pageSize: 5).next();

      expect(pageRequest, PageRequest.create(page: 2, pageSize: 5));
    });

    test('previous never goes below page 1', () {
      final pageRequest = PageRequest.create(page: 1, pageSize: 5).previous();

      expect(pageRequest, PageRequest.create(page: 1, pageSize: 5));
    });

    test('first returns page 1 with the given pageSize', () {
      expect(PageRequest.first(pageSize: 20), PageRequest.create(page: 1, pageSize: 20));
    });

    test('equality is structural', () {
      expect(PageRequest.create(page: 2, pageSize: 10), PageRequest.create(page: 2, pageSize: 10));
    });
  });
}
