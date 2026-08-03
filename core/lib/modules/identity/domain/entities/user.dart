import 'package:core/modules/identity/domain/value_objects/email.dart';
import 'package:core/modules/identity/domain/value_objects/password_hash.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:core/modules/identity/domain/value_objects/username.dart';
import 'package:core/shared/value_objects/timestamp.dart';

class User {
  User._(
    this.id,
    this.createdAt,
    this._email,
    this._username,
    this._passwordHash,
    this._updatedAt,
  );

  factory User.register({
    required Email email,
    required Username username,
    required PasswordHash passwordHash,
  }) {
    final now = Timestamp.now();
    return User._(UserId.generate(), now, email, username, passwordHash, now);
  }

  factory User.fromPersistence({
    required UserId id,
    required Email email,
    required Username username,
    required PasswordHash passwordHash,
    required Timestamp createdAt,
    required Timestamp updatedAt,
  }) {
    return User._(id, createdAt, email, username, passwordHash, updatedAt);
  }

  factory User.empty() {
    final now = Timestamp.empty();
    return User._(
      UserId.empty(),
      now,
      Email.empty(),
      Username.empty(),
      PasswordHash.empty(),
      now,
    );
  }

  final UserId id;
  final Timestamp createdAt;

  Email _email;
  Username _username;
  PasswordHash _passwordHash;
  Timestamp _updatedAt;

  Email get email => _email;
  Username get username => _username;
  PasswordHash get passwordHash => _passwordHash;
  Timestamp get updatedAt => _updatedAt;

  void update({Email? email, Username? username, PasswordHash? passwordHash}) {
    _email = email ?? _email;
    _username = username ?? _username;
    _passwordHash = passwordHash ?? _passwordHash;
    _updatedAt = Timestamp.now();
  }

  @override
  bool operator ==(Object other) => other is User && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
