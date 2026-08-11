import 'package:bloc_test/bloc_test.dart';
import 'package:frontend/modules/identity/application/identity_write_service.dart';
import 'package:frontend/modules/identity/application/login_state_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockIdentityWriteService extends Mock implements IdentityWriteService {}

void main() {
  late MockIdentityWriteService identity;

  setUp(() {
    identity = MockIdentityWriteService();
  });

  group('LoginStateService', () {
    blocTest<LoginStateService, LoginState>(
      'returns to idle on success',
      setUp: () {
        when(
          () => identity.login(
            email: 'jane@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async {});
      },
      build: () => LoginStateService(identity),
      act: (service) =>
          service.submit(email: 'jane@example.com', password: 'password123'),
      expect: () => [isA<LoginInProgress>(), isA<LoginIdle>()],
    );

    blocTest<LoginStateService, LoginState>(
      'emits LoginFailure on error',
      setUp: () {
        when(
          () => identity.login(email: 'jane@example.com', password: 'wrong'),
        ).thenThrow(Exception('invalid credentials'));
      },
      build: () => LoginStateService(identity),
      act: (service) =>
          service.submit(email: 'jane@example.com', password: 'wrong'),
      expect: () => [isA<LoginInProgress>(), isA<LoginFailure>()],
    );
  });
}
