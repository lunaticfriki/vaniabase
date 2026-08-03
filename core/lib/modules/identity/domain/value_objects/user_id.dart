import 'package:core/shared/errors/domain_error.dart';
import 'package:core/shared/generate_uuid_util.dart';

final _uuidV4Pattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

class UserId {
  const UserId._(this.value);

  factory UserId.generate() => UserId._(generateUuidV4Util());

  factory UserId.create(String value) {
    if (!_uuidV4Pattern.hasMatch(value)) {
      throw InvalidUserIdError(value);
    }
    return UserId._(value);
  }

  factory UserId.empty() =>
      const UserId._('00000000-0000-0000-0000-000000000000');

  final String value;

  @override
  bool operator ==(Object other) => other is UserId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidUserIdError extends DomainError {
  InvalidUserIdError(String value) : super('"$value" is not a valid user id');
}
