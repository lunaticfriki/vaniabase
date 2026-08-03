import 'package:core/modules/catalog/domain/value_objects/category.dart';
import 'package:core/modules/catalog/domain/value_objects/format.dart';
import 'package:core/shared/errors/domain_error.dart';

class InvalidFormatForCategoryError extends DomainError {
  InvalidFormatForCategoryError(Category category, Format format)
    : super(
        '"${format.name}" is not a valid format for category '
        '"${category.name}"',
      );
}
