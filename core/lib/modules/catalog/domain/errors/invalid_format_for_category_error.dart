import 'package:core/modules/catalog/domain/value_objects/category.dart';
import 'package:core/modules/catalog/domain/value_objects/item_formats.dart';
import 'package:core/shared/errors/domain_error.dart';

class InvalidFormatForCategoryError extends DomainError {
  InvalidFormatForCategoryError(Category category, ItemFormats formats)
      : super(
          '"$formats" is not a valid set of formats for category '
          '"${category.name}"',
        );
}
