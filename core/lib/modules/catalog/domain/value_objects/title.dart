import 'package:core/shared/errors/domain_error.dart';

class Title {
  const Title._(this.value);

  factory Title.create(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > 200) {
      throw InvalidTitleError(value);
    }
    return Title._(trimmed);
  }

  factory Title.empty() => const Title._('');

  final String value;

  @override
  bool operator ==(Object other) => other is Title && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidTitleError extends DomainError {
  InvalidTitleError(String value)
    : super('"$value" is not a valid title (1-200 characters)');
}
