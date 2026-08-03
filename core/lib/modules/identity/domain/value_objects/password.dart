import 'package:core/shared/errors/domain_error.dart';

final _hasLetter = RegExp(r'[a-zA-Z]');
final _hasDigit = RegExp(r'[0-9]');

class Password {
  const Password._(this.value);

  factory Password.create(String value) {
    if (value.length < 8 ||
        value.length > 128 ||
        !_hasLetter.hasMatch(value) ||
        !_hasDigit.hasMatch(value)) {
      throw WeakPasswordError();
    }
    return Password._(value);
  }

  final String value;

  @override
  bool operator ==(Object other) => other is Password && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '*' * value.length;
}

class WeakPasswordError extends DomainError {
  WeakPasswordError()
    : super(
        'password must be 8-128 characters and contain at least one letter '
        'and one digit',
      );
}
