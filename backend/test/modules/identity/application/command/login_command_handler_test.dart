import 'package:backend/modules/identity/application/access_token_issuer.dart';
import 'package:backend/modules/identity/application/command/login_command.dart';
import 'package:backend/modules/identity/application/command/login_command_handler.dart';
import 'package:core/modules/identity/domain/errors/invalid_credentials_error.dart';
import 'package:core/modules/identity/domain/repositories/refresh_token_repository.dart';
import 'package:core/modules/identity/domain/repositories/user_repository.dart';
import 'package:core/modules/identity/domain/services/password_hasher.dart';
import 'package:core/modules/identity/domain/value_objects/email.dart';
import 'package:core/modules/identity/domain/value_objects/password_hash.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../../../core/test/modules/identity/domain/entities/refresh_token_mother.dart';
import '../../../../../../core/test/modules/identity/domain/entities/user_mother.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockPasswordHasher extends Mock implements PasswordHasher {}

class MockRefreshTokenRepository extends Mock
    implements RefreshTokenRepository {}

class MockAccessTokenIssuer extends Mock implements AccessTokenIssuer {}

void main() {
  setUpAll(() {
    registerFallbackValue(Email.empty());
    registerFallbackValue(PasswordHash.create('fallback-hash'));
    registerFallbackValue(RefreshTokenMother.random());
  });

  group('LoginCommandHandler', () {
    test('returns a session for valid credentials', () async {
      final users = MockUserRepository();
      final hasher = MockPasswordHasher();
      final refreshTokens = MockRefreshTokenRepository();
      final accessTokens = MockAccessTokenIssuer();
      final user = UserMother.random();
      when(() => users.findByEmail(any())).thenAnswer((_) async => user);
      when(() => hasher.verify('password123', user.passwordHash))
          .thenReturn(true);
      when(() => accessTokens.issue(user.id)).thenReturn(
        IssuedAccessToken(
          token: 'access-token',
          expiresAt: DateTime.now().add(const Duration(minutes: 15)),
        ),
      );
      when(() => refreshTokens.save(any())).thenAnswer((_) async {});

      final handler = LoginCommandHandler(
        users,
        hasher,
        refreshTokens,
        accessTokens,
      );
      final session = await handler.handle(
        const LoginCommand(email: 'jane.doe@example.com', password: 'password123'),
      );

      expect(session.accessToken, 'access-token');
      expect(session.refreshToken, isNotEmpty);
      verify(() => refreshTokens.save(any())).called(1);
    });

    test('throws when no user has that email', () async {
      final users = MockUserRepository();
      final hasher = MockPasswordHasher();
      final refreshTokens = MockRefreshTokenRepository();
      final accessTokens = MockAccessTokenIssuer();
      when(() => users.findByEmail(any())).thenAnswer((_) async => null);

      final handler = LoginCommandHandler(
        users,
        hasher,
        refreshTokens,
        accessTokens,
      );

      expect(
        () => handler.handle(
          const LoginCommand(email: 'jane.doe@example.com', password: 'wrong'),
        ),
        throwsA(isA<InvalidCredentialsError>()),
      );
    });

    test('throws when the password does not match', () async {
      final users = MockUserRepository();
      final hasher = MockPasswordHasher();
      final refreshTokens = MockRefreshTokenRepository();
      final accessTokens = MockAccessTokenIssuer();
      final user = UserMother.random();
      when(() => users.findByEmail(any())).thenAnswer((_) async => user);
      when(() => hasher.verify(any(), any())).thenReturn(false);

      final handler = LoginCommandHandler(
        users,
        hasher,
        refreshTokens,
        accessTokens,
      );

      expect(
        () => handler.handle(
          const LoginCommand(email: 'jane.doe@example.com', password: 'wrong'),
        ),
        throwsA(isA<InvalidCredentialsError>()),
      );
    });
  });
}
