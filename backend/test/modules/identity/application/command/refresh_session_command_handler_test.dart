import 'package:backend/modules/identity/application/access_token_issuer.dart';
import 'package:backend/modules/identity/application/command/refresh_session_command.dart';
import 'package:backend/modules/identity/application/command/refresh_session_command_handler.dart';
import 'package:core/modules/identity/domain/entities/refresh_token.dart';
import 'package:core/modules/identity/domain/errors/invalid_refresh_token_error.dart';
import 'package:core/modules/identity/domain/repositories/refresh_token_repository.dart';
import 'package:core/modules/identity/domain/value_objects/refresh_token_id.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../../../core/test/modules/identity/domain/entities/refresh_token_mother.dart';

class MockRefreshTokenRepository extends Mock
    implements RefreshTokenRepository {}

class MockAccessTokenIssuer extends Mock implements AccessTokenIssuer {}

void main() {
  setUpAll(() {
    registerFallbackValue(RefreshTokenMother.random());
    registerFallbackValue(RefreshTokenId.generate());
  });

  group('RefreshSessionCommandHandler', () {
    test('rotates a valid refresh token and issues a new access token', () async {
      final refreshTokens = MockRefreshTokenRepository();
      final accessTokens = MockAccessTokenIssuer();
      final existing = RefreshTokenMother.random();
      when(
        () => refreshTokens.findById(existing.id),
      ).thenAnswer((_) async => existing);
      when(() => refreshTokens.save(any())).thenAnswer((_) async {});
      when(() => accessTokens.issue(existing.userId)).thenReturn(
        IssuedAccessToken(
          token: 'new-access-token',
          expiresAt: DateTime.now().add(const Duration(minutes: 15)),
        ),
      );

      final handler = RefreshSessionCommandHandler(refreshTokens, accessTokens);
      final session = await handler.handle(
        RefreshSessionCommand(refreshToken: existing.id.value),
      );

      expect(session.accessToken, 'new-access-token');
      expect(session.refreshToken, isNot(equals(existing.id.value)));
      expect(existing.isRevoked, isTrue);
      verify(() => refreshTokens.save(any())).called(2);
    });

    test('throws when the refresh token does not exist', () async {
      final refreshTokens = MockRefreshTokenRepository();
      final accessTokens = MockAccessTokenIssuer();
      when(
        () => refreshTokens.findById(any()),
      ).thenAnswer((_) async => null);

      final handler = RefreshSessionCommandHandler(refreshTokens, accessTokens);

      expect(
        () => handler.handle(
          RefreshSessionCommand(refreshToken: RefreshTokenId.generate().value),
        ),
        throwsA(isA<InvalidRefreshTokenError>()),
      );
    });

    test('throws when the refresh token is expired', () async {
      final refreshTokens = MockRefreshTokenRepository();
      final accessTokens = MockAccessTokenIssuer();
      final expired = RefreshToken.issue(
        userId: RefreshTokenMother.random().userId,
        validFor: const Duration(milliseconds: -1),
      );
      when(
        () => refreshTokens.findById(expired.id),
      ).thenAnswer((_) async => expired);

      final handler = RefreshSessionCommandHandler(refreshTokens, accessTokens);

      expect(
        () => handler.handle(
          RefreshSessionCommand(refreshToken: expired.id.value),
        ),
        throwsA(isA<InvalidRefreshTokenError>()),
      );
    });

    test('throws when the refresh token is already revoked', () async {
      final refreshTokens = MockRefreshTokenRepository();
      final accessTokens = MockAccessTokenIssuer();
      final revoked = RefreshTokenMother.random()..revoke();
      when(
        () => refreshTokens.findById(revoked.id),
      ).thenAnswer((_) async => revoked);

      final handler = RefreshSessionCommandHandler(refreshTokens, accessTokens);

      expect(
        () => handler.handle(
          RefreshSessionCommand(refreshToken: revoked.id.value),
        ),
        throwsA(isA<InvalidRefreshTokenError>()),
      );
    });
  });
}
