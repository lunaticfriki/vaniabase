import 'package:core/shared/errors/domain_error.dart';

class Topic {
  const Topic._(this.value);

  factory Topic.create(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > 100) {
      throw InvalidTopicError(value);
    }
    return Topic._(trimmed);
  }

  factory Topic.empty() => const Topic._('');

  final String value;

  @override
  bool operator ==(Object other) => other is Topic && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidTopicError extends DomainError {
  InvalidTopicError(String value)
      : super('"$value" is not a valid topic (1-100 characters)');
}
