import 'package:bloc_test/bloc_test.dart';
import 'package:frontend/shared/session/session_cubit.dart';
import 'package:frontend/shared/session/session_state.dart';
import 'package:frontend/shared/session/session_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockSessionStorage extends Mock implements SessionStorage {}

void main() {
  late MockSessionStorage storage;

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
    storage = MockSessionStorage();
  });

  group('SessionCubit', () {
    blocTest<SessionCubit, SessionState>(
      'authenticate persists the session and emits SessionAuthenticated',
      setUp: () => when(() => storage.save(any())).thenAnswer((_) async {}),
      build: () => SessionCubit(storage),
      act: (cubit) => cubit.authenticate(
        accessToken: 'access-token',
        accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 15)),
        refreshToken: 'refresh-token',
      ),
      expect: () => [isA<SessionAuthenticated>()],
      verify: (_) {
        verify(
          () => storage.save(
            any(
              that: isA<StoredSession>().having(
                (s) => s.accessToken,
                'accessToken',
                'access-token',
              ),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<SessionCubit, SessionState>(
      'clear wipes storage and emits SessionUnauthenticated',
      setUp: () => when(() => storage.clear()).thenAnswer((_) async {}),
      build: () => SessionCubit(storage),
      act: (cubit) => cubit.clear(),
      expect: () => [isA<SessionUnauthenticated>()],
      verify: (_) => verify(() => storage.clear()).called(1),
    );

    blocTest<SessionCubit, SessionState>(
      'restore rehydrates a non-expired stored session',
      setUp: () => when(() => storage.load()).thenAnswer(
        (_) async => StoredSession(
          accessToken: 'access-token',
          accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 15)),
          refreshToken: 'refresh-token',
        ),
      ),
      build: () => SessionCubit(storage),
      act: (cubit) => cubit.restore(),
      expect: () => [isA<SessionAuthenticated>()],
    );

    blocTest<SessionCubit, SessionState>(
      'restore discards and clears an expired stored session',
      setUp: () {
        when(() => storage.load()).thenAnswer(
          (_) async => StoredSession(
            accessToken: 'access-token',
            accessTokenExpiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
            refreshToken: 'refresh-token',
          ),
        );
        when(() => storage.clear()).thenAnswer((_) async {});
      },
      build: () => SessionCubit(storage),
      act: (cubit) => cubit.restore(),
      expect: () => [],
      verify: (_) => verify(() => storage.clear()).called(1),
    );

    blocTest<SessionCubit, SessionState>(
      'restore is a no-op when nothing was stored',
      setUp: () => when(() => storage.load()).thenAnswer((_) async => null),
      build: () => SessionCubit(storage),
      act: (cubit) => cubit.restore(),
      expect: () => [],
    );
  });
}
