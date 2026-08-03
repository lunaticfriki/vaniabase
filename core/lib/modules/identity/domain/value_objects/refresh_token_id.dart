import 'package:core/shared/errors/domain_error.dart';
import 'package:core/shared/generate_secure_token_util.dart';

final _hex64Pattern = RegExp(r'^[0-9a-f]{64}$');

class RefreshTokenId {
  const RefreshTokenId._(this.value);

  factory RefreshTokenId.generate() =>
      RefreshTokenId._(generateSecureTokenUtil());

  factory RefreshTokenId.create(String value) {
    if (!_hex64Pattern.hasMatch(value)) {
      throw InvalidRefreshTokenIdError(value);
    }
    return RefreshTokenId._(value);
  }

  factory RefreshTokenId.empty() => RefreshTokenId._('0' * 64);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is RefreshTokenId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidRefreshTokenIdError extends DomainError {
  InvalidRefreshTokenIdError(String value)
    : super('"$value" is not a valid refresh token id');
}
