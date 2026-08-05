import 'package:bloc_test/bloc_test.dart';
import 'package:frontend/modules/identity/application/identity_write_service.dart';
import 'package:frontend/modules/identity/application/login_state.dart';
import 'package:frontend/modules/identity/application/login_state_service.dart';
import 'package:frontend/modules/identity/application/session_read_model.dart';
import 'package:frontend/shared/session/session_state.dart';
import 'package:frontend/shared/session/session_state_service.dart';
import 'package:frontend/shared/session/session_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockIdentityWriteService extends Mock implements IdentityWriteService {}

class MockSessionStorage extends Mock implements SessionStorage {}

void main() {
  late MockIdentityWriteService identity;
  late MockSessionStorage sessionStorage;
  late SessionStateService session;

  setUpAll(() {
    registerFallbackValue(
      StoredSession(
        accessToken: 'fallback',
        accessTokenExpiresAt: DateTime.now(),
        refreshToken: 'fallback',
      ),
    );
  });

  setUp(() {
    identity = MockIdentityWriteService();
    sessionStorage = MockSessionStorage();
    when(() => sessionStorage.save(any())).thenAnswer((_) async {});
    when(() => sessionStorage.clear()).thenAnswer((_) async {});
    session = SessionStateService(sessionStorage);
  });

  group('LoginStateService', () {
    blocTest<LoginStateService, LoginState>(
      'authenticates the session and returns to idle on success',
      setUp: () {
        when(
          () => identity.login(email: 'jane@example.com', password: 'password123'),
        ).thenAnswer(
          (_) async => SessionReadModel(
            accessToken: 'access-token',
            accessTokenExpiresAt: DateTime.now(),
            refreshToken: 'refresh-token',
          ),
        );
      },
      build: () => LoginStateService(identity, session),
      act: (service) => service.submit(email: 'jane@example.com', password: 'password123'),
      expect: () => [isA<LoginInProgress>(), isA<LoginIdle>()],
      verify: (_) {
        expect(session.state, isA<SessionAuthenticated>());
        expect(session.accessToken, 'access-token');
      },
    );

    blocTest<LoginStateService, LoginState>(
      'emits LoginFailure and leaves the session unauthenticated on error',
      setUp: () {
        when(
          () => identity.login(email: 'jane@example.com', password: 'wrong'),
        ).thenThrow(Exception('invalid credentials'));
      },
      build: () => LoginStateService(identity, session),
      act: (service) => service.submit(email: 'jane@example.com', password: 'wrong'),
      expect: () => [isA<LoginInProgress>(), isA<LoginFailure>()],
      verify: (_) {
        expect(session.state, isA<SessionUnauthenticated>());
      },
    );
  });
}
