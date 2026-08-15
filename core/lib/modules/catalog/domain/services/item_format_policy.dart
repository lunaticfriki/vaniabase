import 'package:core/modules/catalog/domain/value_objects/category.dart';
import 'package:core/modules/catalog/domain/value_objects/format.dart';
import 'package:core/modules/catalog/domain/value_objects/item_formats.dart';

class ItemFormatPolicy {
  static const Map<Category, Set<Format>> _allowedFormats = {
    Category.book: {Format.hardcover, Format.paperback, Format.ebook},
    Category.comic: {Format.hardcover, Format.paperback, Format.ebook},
    Category.magazine: {Format.paperback, Format.digitalDownload},
    Category.movie: {Format.dvd, Format.bluRay, Format.digitalDownload},
    Category.videogame: {
      Format.cartridge,
      Format.dvd,
      Format.bluRay,
      Format.digitalDownload,
    },
    Category.musicAlbum: {
      Format.cd,
      Format.vinyl,
      Format.cassette,
      Format.digitalDownload,
    },
  };

  /// Every format in [formats] must be allowed for [category].
  static bool allows(Category category, ItemFormats formats) {
    final allowed = _allowedFormats[category];
    if (allowed == null) return false;
    return formats.value.every(allowed.contains);
  }
}
