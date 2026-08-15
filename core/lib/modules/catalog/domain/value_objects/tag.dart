import 'package:core/shared/errors/domain_error.dart';

class Tag {
  const Tag._(this.value);

  factory Tag.create(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty || normalized.length > 30) {
      throw InvalidTagError(value);
    }
    return Tag._(normalized);
  }

  final String value;

  @override
  bool operator ==(Object other) => other is Tag && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidTagError extends DomainError {
  InvalidTagError(String value)
      : super('"$value" is not a valid tag (1-30 characters)');
}
