import 'package:core/modules/catalog/domain/services/item_format_policy.dart';
import 'package:core/modules/catalog/domain/value_objects/category.dart';
import 'package:core/modules/catalog/domain/value_objects/format.dart';
import 'package:core/modules/catalog/domain/value_objects/item_formats.dart';
import 'package:test/test.dart';

ItemFormats _formats(List<Format> formats) => ItemFormats.create(formats);

void main() {
  group('ItemFormatPolicy', () {
    test('book allows hardcover, paperback and ebook', () {
      expect(
        ItemFormatPolicy.allows(Category.book, _formats([Format.hardcover])),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(Category.book, _formats([Format.paperback])),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(Category.book, _formats([Format.ebook])),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(Category.book, _formats([Format.vinyl])),
        isFalse,
      );
    });

    test('comic allows hardcover, paperback and ebook', () {
      expect(
        ItemFormatPolicy.allows(Category.comic, _formats([Format.hardcover])),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(Category.comic, _formats([Format.paperback])),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(Category.comic, _formats([Format.ebook])),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(Category.comic, _formats([Format.dvd])),
        isFalse,
      );
    });

    test('magazine allows paperback and digital download', () {
      expect(
        ItemFormatPolicy.allows(
          Category.magazine,
          _formats([Format.paperback]),
        ),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(
          Category.magazine,
          _formats([Format.digitalDownload]),
        ),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(
          Category.magazine,
          _formats([Format.hardcover]),
        ),
        isFalse,
      );
    });

    test('movie allows dvd, bluRay, vhs and digital download', () {
      expect(
        ItemFormatPolicy.allows(Category.movie, _formats([Format.dvd])),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(Category.movie, _formats([Format.bluRay])),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(Category.movie, _formats([Format.vhs])),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(
          Category.movie,
          _formats([Format.digitalDownload]),
        ),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(Category.movie, _formats([Format.cd])),
        isFalse,
      );
    });

    test(
        'videogame allows cartridge, dvd, bluRay, miniDisc and digital download',
        () {
      expect(
        ItemFormatPolicy.allows(
          Category.videogame,
          _formats([Format.cartridge]),
        ),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(Category.videogame, _formats([Format.dvd])),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(
          Category.videogame,
          _formats([Format.bluRay]),
        ),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(
          Category.videogame,
          _formats([Format.miniDisc]),
        ),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(
          Category.videogame,
          _formats([Format.digitalDownload]),
        ),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(Category.videogame, _formats([Format.vinyl])),
        isFalse,
      );
    });

    test(
        'musicAlbum allows cd, vinyl, cassette, miniDisc and digital download',
        () {
      expect(
        ItemFormatPolicy.allows(Category.musicAlbum, _formats([Format.cd])),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(
          Category.musicAlbum,
          _formats([Format.vinyl]),
        ),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(
          Category.musicAlbum,
          _formats([Format.cassette]),
        ),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(
          Category.musicAlbum,
          _formats([Format.miniDisc]),
        ),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(
          Category.musicAlbum,
          _formats([Format.digitalDownload]),
        ),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(
          Category.musicAlbum,
          _formats([Format.cartridge]),
        ),
        isFalse,
      );
    });

    test(
        'allows every format in a multi-format set only when all are valid for the category',
        () {
      expect(
        ItemFormatPolicy.allows(
          Category.movie,
          _formats([Format.dvd, Format.bluRay]),
        ),
        isTrue,
      );
      expect(
        ItemFormatPolicy.allows(
          Category.movie,
          _formats([Format.dvd, Format.cd]),
        ),
        isFalse,
      );
    });
  });
}
