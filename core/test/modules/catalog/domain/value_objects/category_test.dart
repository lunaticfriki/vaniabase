import 'package:core/modules/catalog/domain/value_objects/category.dart';
import 'package:test/test.dart';

void main() {
  group('Category', () {
    test('parse accepts a valid category name', () {
      expect(Category.parse('book'), Category.book);
      expect(Category.parse('musicAlbum'), Category.musicAlbum);
    });

    test('parse throws for an unknown name', () {
      expect(
        () => Category.parse('not-a-category'),
        throwsA(isA<InvalidCategoryError>()),
      );
    });
  });
}
