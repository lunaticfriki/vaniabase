import 'package:core/shared/errors/domain_error.dart';

class Reference {
  const Reference._(this.value);

  factory Reference.create(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > 50) {
      throw InvalidReferenceError(value);
    }
    return Reference._(trimmed);
  }

  factory Reference.empty() => const Reference._('');

  final String value;

  @override
  bool operator ==(Object other) => other is Reference && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidReferenceError extends DomainError {
  InvalidReferenceError(String value)
    : super('"$value" is not a valid reference (1-50 characters)');
}
