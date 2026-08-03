import 'package:backend/modules/identity/application/command/logout_command.dart';
import 'package:backend/modules/identity/application/command/logout_command_handler.dart';
import 'package:core/modules/identity/domain/repositories/refresh_token_repository.dart';
import 'package:core/modules/identity/domain/value_objects/refresh_token_id.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../../../core/test/modules/identity/domain/entities/refresh_token_mother.dart';

class MockRefreshTokenRepository extends Mock
    implements RefreshTokenRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(RefreshTokenMother.random());
    registerFallbackValue(RefreshTokenId.generate());
  });

  group('LogoutCommandHandler', () {
    test('revokes an existing refresh token', () async {
      final refreshTokens = MockRefreshTokenRepository();
      final existing = RefreshTokenMother.random();
      when(
        () => refreshTokens.findById(existing.id),
      ).thenAnswer((_) async => existing);
      when(() => refreshTokens.save(any())).thenAnswer((_) async {});

      final handler = LogoutCommandHandler(refreshTokens);
      await handler.handle(LogoutCommand(refreshToken: existing.id.value));

      expect(existing.isRevoked, isTrue);
      verify(() => refreshTokens.save(existing)).called(1);
    });

    test('is a no-op when the refresh token does not exist', () async {
      final refreshTokens = MockRefreshTokenRepository();
      when(() => refreshTokens.findById(any())).thenAnswer((_) async => null);

      final handler = LogoutCommandHandler(refreshTokens);

      await handler.handle(
        LogoutCommand(refreshToken: RefreshTokenId.generate().value),
      );

      verifyNever(() => refreshTokens.save(any()));
    });
  });
}
