import 'package:core/shared/errors/domain_error.dart';

class PasswordHash {
  const PasswordHash._(this.value);

  factory PasswordHash.create(String value) {
    if (value.isEmpty || value.length > 200) {
      throw InvalidPasswordHashError();
    }
    return PasswordHash._(value);
  }

  factory PasswordHash.empty() => const PasswordHash._('');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is PasswordHash && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidPasswordHashError extends DomainError {
  InvalidPasswordHashError() : super('password hash must be 1-200 characters');
}
