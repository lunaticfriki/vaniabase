import 'package:core/shared/errors/domain_error.dart';

class ImageUrl {
  const ImageUrl._(this.value);

  factory ImageUrl.create(String value) {
    final uri = Uri.tryParse(value);
    final isValid = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!isValid) {
      throw InvalidImageUrlError(value);
    }
    return ImageUrl._(value);
  }

  factory ImageUrl.empty() => const ImageUrl._('');

  final String value;

  @override
  bool operator ==(Object other) => other is ImageUrl && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidImageUrlError extends DomainError {
  InvalidImageUrlError(String value)
      : super('"$value" is not a valid http/https image URL');
}
