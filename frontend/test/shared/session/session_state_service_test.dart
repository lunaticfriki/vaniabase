import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/shared/session/session_state.dart';
import 'package:frontend/shared/session/session_state_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth firebaseAuth;

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
  });

  group('SessionStateService', () {
    blocTest<SessionStateService, SessionState>(
      'emits SessionAuthenticated when Firebase reports a signed-in user',
      setUp: () {
        final user = MockUser();
        when(() => user.uid).thenReturn('user-1');
        when(() => user.email).thenReturn('jane@example.com');
        when(() => firebaseAuth.authStateChanges()).thenAnswer((_) => Stream.value(user));
      },
      build: () => SessionStateService(firebaseAuth),
      expect: () => [
        isA<SessionAuthenticated>()
            .having((s) => s.uid, 'uid', 'user-1')
            .having((s) => s.email, 'email', 'jane@example.com'),
      ],
    );

    blocTest<SessionStateService, SessionState>(
      'emits SessionUnauthenticated when Firebase reports no user',
      setUp: () => when(() => firebaseAuth.authStateChanges()).thenAnswer((_) => Stream.value(null)),
      build: () => SessionStateService(firebaseAuth),
      expect: () => [isA<SessionUnauthenticated>()],
    );

    blocTest<SessionStateService, SessionState>(
      'clear signs out through FirebaseAuth',
      setUp: () {
        when(() => firebaseAuth.authStateChanges()).thenAnswer((_) => const Stream.empty());
        when(() => firebaseAuth.signOut()).thenAnswer((_) async {});
      },
      build: () => SessionStateService(firebaseAuth),
      act: (service) => service.clear(),
      expect: () => [],
      verify: (_) => verify(() => firebaseAuth.signOut()).called(1),
    );
  });
}
