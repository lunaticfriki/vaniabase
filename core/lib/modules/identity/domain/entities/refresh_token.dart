import 'package:core/modules/identity/domain/value_objects/refresh_token_id.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:core/shared/value_objects/timestamp.dart';

class RefreshToken {
  RefreshToken._(
    this.id,
    this.userId,
    this.createdAt,
    this.expiresAt,
    this._revoked,
  );

  factory RefreshToken.issue({
    required UserId userId,
    required Duration validFor,
  }) {
    final now = Timestamp.now();
    return RefreshToken._(
      RefreshTokenId.generate(),
      userId,
      now,
      Timestamp.at(now.value.add(validFor)),
      false,
    );
  }

  factory RefreshToken.fromPersistence({
    required RefreshTokenId id,
    required UserId userId,
    required Timestamp createdAt,
    required Timestamp expiresAt,
    required bool revoked,
  }) {
    return RefreshToken._(id, userId, createdAt, expiresAt, revoked);
  }

  factory RefreshToken.empty() {
    final now = Timestamp.empty();
    return RefreshToken._(
        RefreshTokenId.empty(), UserId.empty(), now, now, false);
  }

  final RefreshTokenId id;
  final UserId userId;
  final Timestamp createdAt;
  final Timestamp expiresAt;

  bool _revoked;

  bool get isRevoked => _revoked;

  bool get isExpired => Timestamp.now().isAfter(expiresAt);

  bool get isValid => !_revoked && !isExpired;

  void revoke() {
    _revoked = true;
  }

  @override
  bool operator ==(Object other) => other is RefreshToken && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
