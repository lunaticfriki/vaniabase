import 'package:core/modules/identity/domain/entities/refresh_token.dart';
import 'package:core/modules/identity/domain/value_objects/refresh_token_id.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:core/shared/value_objects/timestamp.dart';
import 'package:test/test.dart';

import 'refresh_token_mother.dart';
import 'user_mother.dart';

void main() {
  group('RefreshToken', () {
    test('issue creates a token valid for the given duration', () {
      final userId = UserMother.random().id;

      final token = RefreshToken.issue(
        userId: userId,
        validFor: const Duration(days: 30),
      );

      expect(token.userId, userId);
      expect(token.id, isNot(equals(RefreshTokenId.empty())));
      expect(token.expiresAt.isAfter(token.createdAt), isTrue);
      expect(token.isValid, isTrue);
    });

    test('empty returns the neutral instance', () {
      final token = RefreshToken.empty();

      expect(token.id, RefreshTokenId.empty());
      expect(token.userId, UserId.empty());
    });

    test('isExpired is true once expiresAt has passed', () {
      final token = RefreshToken.issue(
        userId: UserMother.random().id,
        validFor: const Duration(milliseconds: -1),
      );

      expect(token.isExpired, isTrue);
      expect(token.isValid, isFalse);
    });

    test('isExpired is false while still within validFor', () {
      final token = RefreshTokenMother.random();

      expect(token.isExpired, isFalse);
    });

    test('revoke makes the token invalid even if not expired', () {
      final token = RefreshTokenMother.random();

      token.revoke();

      expect(token.isRevoked, isTrue);
      expect(token.isValid, isFalse);
    });

    test('equality does not change when the token is revoked', () {
      final token = RefreshTokenMother.random();
      final reference = token;

      token.revoke();

      expect(token, equals(reference));
    });

    test('two tokens with different ids are not equal', () {
      final first = RefreshTokenMother.random();
      final second = RefreshTokenMother.random();

      expect(first, isNot(equals(second)));
    });

    test('fromPersistence rebuilds a token with its existing identity', () {
      final id = RefreshTokenId.generate();
      final userId = UserMother.random().id;
      final createdAt = Timestamp.create(DateTime(2020, 1, 1));
      final expiresAt = Timestamp.at(DateTime(2020, 2, 1));

      final token = RefreshToken.fromPersistence(
        id: id,
        userId: userId,
        createdAt: createdAt,
        expiresAt: expiresAt,
        revoked: true,
      );

      expect(token.id, id);
      expect(token.userId, userId);
      expect(token.createdAt, createdAt);
      expect(token.expiresAt, expiresAt);
      expect(token.isRevoked, isTrue);
    });
  });
}
