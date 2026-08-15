import 'package:core/shared/errors/domain_error.dart';

final _usernamePattern = RegExp(r'^[a-zA-Z0-9_]{3,30}$');

class Username {
  const Username._(this.value);

  factory Username.create(String value) {
    final trimmed = value.trim();
    if (!_usernamePattern.hasMatch(trimmed)) {
      throw InvalidUsernameError(value);
    }
    return Username._(trimmed);
  }

  factory Username.empty() => const Username._('');

  final String value;

  @override
  bool operator ==(Object other) => other is Username && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidUsernameError extends DomainError {
  InvalidUsernameError(String value)
      : super(
          '"$value" is not a valid username '
          '(3-30 chars, letters/digits/underscore only)',
        );
}
