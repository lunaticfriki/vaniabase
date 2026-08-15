import 'package:core/shared/errors/domain_error.dart';

enum Category {
  book,
  comic,
  magazine,
  movie,
  videogame,
  musicAlbum;

  static Category parse(String value) {
    return Category.values.firstWhere(
      (category) => category.name == value,
      orElse: () => throw InvalidCategoryError(value),
    );
  }
}

class InvalidCategoryError extends DomainError {
  InvalidCategoryError(String value)
      : super('"$value" is not a valid category');
}
