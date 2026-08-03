import 'package:core/modules/identity/domain/entities/user.dart';
import 'package:core/modules/identity/domain/value_objects/email.dart';
import 'package:core/modules/identity/domain/value_objects/password_hash.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:core/modules/identity/domain/value_objects/username.dart';
import 'package:core/shared/value_objects/timestamp.dart';
import 'package:test/test.dart';

import 'user_mother.dart';

void main() {
  group('User', () {
    test('register creates a user with the given fields', () {
      final email = Email.create('jane.doe@example.com');
      final username = Username.create('jane_doe');
      final passwordHash = PasswordHash.create('hashed-password-value');

      final user = User.register(
        email: email,
        username: username,
        passwordHash: passwordHash,
      );

      expect(user.email, email);
      expect(user.username, username);
      expect(user.passwordHash, passwordHash);
      expect(user.id, isNot(equals(UserId.empty())));
      expect(user.createdAt, user.updatedAt);
    });

    test('empty returns the neutral instance', () {
      final user = User.empty();

      expect(user.id, UserId.empty());
      expect(user.email, Email.empty());
      expect(user.username, Username.empty());
      expect(user.passwordHash, PasswordHash.empty());
    });

    test('update changes only the provided fields', () {
      final user = UserMother.random();
      final originalUsername = user.username;
      final originalPasswordHash = user.passwordHash;
      final newEmail = Email.create('new.email@example.com');

      user.update(email: newEmail);

      expect(user.email, newEmail);
      expect(user.username, originalUsername);
      expect(user.passwordHash, originalPasswordHash);
    });

    test('update bumps updatedAt but not createdAt', () async {
      final user = UserMother.random();
      final originalCreatedAt = user.createdAt;
      final originalUpdatedAt = user.updatedAt;

      await Future<void>.delayed(const Duration(milliseconds: 5));
      user.update(username: Username.create('new_username'));

      expect(user.createdAt, originalCreatedAt);
      expect(user.updatedAt, isNot(equals(originalUpdatedAt)));
    });

    test('equality does not change when mutable fields are updated', () {
      final user = UserMother.random();
      final reference = user;

      user.update(username: Username.create('changed_username'));

      expect(user, equals(reference));
    });

    test('two users with different ids are not equal', () {
      final first = UserMother.random();
      final second = User.register(
        email: first.email,
        username: first.username,
        passwordHash: first.passwordHash,
      );

      expect(first, isNot(equals(second)));
    });

    test('fromPersistence rebuilds a user with its existing identity', () {
      final id = UserId.generate();
      final createdAt = Timestamp.create(DateTime(2020, 1, 1));
      final updatedAt = Timestamp.create(DateTime(2021, 6, 1));
      final email = Email.create('jane.doe@example.com');
      final username = Username.create('jane_doe');
      final passwordHash = PasswordHash.create('hashed-password-value');

      final user = User.fromPersistence(
        id: id,
        email: email,
        username: username,
        passwordHash: passwordHash,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(user.id, id);
      expect(user.email, email);
      expect(user.username, username);
      expect(user.passwordHash, passwordHash);
      expect(user.createdAt, createdAt);
      expect(user.updatedAt, updatedAt);
    });
  });
}
