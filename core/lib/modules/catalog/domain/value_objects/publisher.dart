import 'package:core/shared/errors/domain_error.dart';

class Publisher {
  const Publisher._(this.value);

  factory Publisher.create(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > 150) {
      throw InvalidPublisherError(value);
    }
    return Publisher._(trimmed);
  }

  factory Publisher.empty() => const Publisher._('');

  final String value;

  @override
  bool operator ==(Object other) => other is Publisher && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidPublisherError extends DomainError {
  InvalidPublisherError(String value)
      : super('"$value" is not a valid publisher (1-150 characters)');
}
