import 'package:core/modules/catalog/domain/services/item_format_policy.dart';
import 'package:core/modules/catalog/domain/value_objects/category.dart';
import 'package:core/modules/catalog/domain/value_objects/format.dart';
import 'package:test/test.dart';

void main() {
  group('ItemFormatPolicy', () {
    test('book allows hardcover, paperback and ebook', () {
      expect(ItemFormatPolicy.allows(Category.book, Format.hardcover), isTrue);
      expect(ItemFormatPolicy.allows(Category.book, Format.paperback), isTrue);
      expect(ItemFormatPolicy.allows(Category.book, Format.ebook), isTrue);
      expect(ItemFormatPolicy.allows(Category.book, Format.vinyl), isFalse);
    });

    test('comic allows hardcover, paperback and ebook', () {
      expect(ItemFormatPolicy.allows(Category.comic, Format.hardcover), isTrue);
      expect(ItemFormatPolicy.allows(Category.comic, Format.paperback), isTrue);
      expect(ItemFormatPolicy.allows(Category.comic, Format.ebook), isTrue);
      expect(ItemFormatPolicy.allows(Category.comic, Format.dvd), isFalse);
    });

    test('magazine allows paperback and digital download', () {
      expect(
        ItemFormatPolicy.allows(Category.magazine, Format.paperback),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(Category.magazine, Format.digitalDownload),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(Category.magazine, Format.hardcover),
        isFalse,
      );
    });

    test('movie allows dvd, bluRay and digital download', () {
      expect(ItemFormatPolicy.allows(Category.movie, Format.dvd), isTrue);
      expect(ItemFormatPolicy.allows(Category.movie, Format.bluRay), isTrue);
      expect(
        ItemFormatPolicy.allows(Category.movie, Format.digitalDownload),
        isTrue,
      );
      expect(ItemFormatPolicy.allows(Category.movie, Format.cd), isFalse);
    });

    test('videogame allows cartridge, dvd, bluRay and digital download', () {
      expect(
        ItemFormatPolicy.allows(Category.videogame, Format.cartridge),
        isTrue,
      );
      expect(ItemFormatPolicy.allows(Category.videogame, Format.dvd), isTrue);
      expect(
        ItemFormatPolicy.allows(Category.videogame, Format.bluRay),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(Category.videogame, Format.digitalDownload),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(Category.videogame, Format.vinyl),
        isFalse,
      );
    });

    test('musicAlbum allows cd, vinyl and digital download', () {
      expect(ItemFormatPolicy.allows(Category.musicAlbum, Format.cd), isTrue);
      expect(
        ItemFormatPolicy.allows(Category.musicAlbum, Format.vinyl),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(Category.musicAlbum, Format.digitalDownload),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(Category.musicAlbum, Format.cartridge),
        isFalse,
      );
    });
  });
}
