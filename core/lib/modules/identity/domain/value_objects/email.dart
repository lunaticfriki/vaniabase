import 'package:core/shared/errors/domain_error.dart';

class Email {
  const Email._(this.value);

  factory Email.create(String value) {
    final normalized = value.trim().toLowerCase();
    if (!_isValid(normalized)) {
      throw InvalidEmailError(value);
    }
    return Email._(normalized);
  }

  factory Email.empty() => const Email._('');

  final String value;

  static bool _isValid(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }

  @override
  bool operator ==(Object other) => other is Email && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidEmailError extends DomainError {
  InvalidEmailError(String value) : super('"$value" is not a valid email');
}
