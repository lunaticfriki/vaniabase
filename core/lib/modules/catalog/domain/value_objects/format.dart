import 'package:core/shared/errors/domain_error.dart';

enum Format {
  hardcover,
  paperback,
  ebook,
  dvd,
  bluRay,
  vhs,
  cd,
  vinyl,
  cassette,
  miniDisc,
  cartridge,
  digitalDownload;

  static Format parse(String value) {
    return Format.values.firstWhere(
      (format) => format.name == value,
      orElse: () => throw InvalidFormatError(value),
    );
  }
}

class InvalidFormatError extends DomainError {
  InvalidFormatError(String value) : super('"$value" is not a valid format');
}
