import 'package:core/modules/catalog/domain/value_objects/category.dart';
import 'package:core/modules/catalog/domain/value_objects/format.dart';

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
    Category.musicAlbum: {Format.cd, Format.vinyl, Format.digitalDownload},
  };

  static bool allows(Category category, Format format) {
    return _allowedFormats[category]?.contains(format) ?? false;
  }
}
