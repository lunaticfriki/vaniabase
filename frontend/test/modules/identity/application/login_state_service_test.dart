import 'package:bloc_test/bloc_test.dart';
import 'package:frontend/modules/identity/application/identity_write_service.dart';
import 'package:frontend/modules/identity/application/login_state_service.dart';
import 'package:frontend/modules/identity/application/remembered_account.dart';
import 'package:frontend/modules/identity/application/remembered_accounts_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockIdentityWriteService extends Mock implements IdentityWriteService {}

class MockRememberedAccountsRepository extends Mock
    implements RememberedAccountsRepository {}

void main() {
  late MockIdentityWriteService identity;
  late MockRememberedAccountsRepository rememberedAccounts;

  setUp(() {
    identity = MockIdentityWriteService();
    rememberedAccounts = MockRememberedAccountsRepository();
    when(() => rememberedAccounts.getAll()).thenAnswer((_) async => []);
    when(
      () => rememberedAccounts.remember(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
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
      build: () => LoginStateService(identity, rememberedAccounts),
      act: (service) =>
          service.submit(email: 'jane@example.com', password: 'password123'),
      expect: () => [
        isA<LoginIdle>(),
        isA<LoginInProgress>(),
        isA<LoginIdle>(),
      ],
      verify: (_) {
        verify(
          () => rememberedAccounts.remember(
            email: 'jane@example.com',
            password: null,
          ),
        ).called(1);
      },
    );

    blocTest<LoginStateService, LoginState>(
      'stores the password when rememberPassword is true',
      setUp: () {
        when(
          () => identity.login(
            email: 'jane@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async {});
      },
      build: () => LoginStateService(identity, rememberedAccounts),
      act: (service) => service.submit(
        email: 'jane@example.com',
        password: 'password123',
        rememberPassword: true,
      ),
      expect: () => [
        isA<LoginIdle>(),
        isA<LoginInProgress>(),
        isA<LoginIdle>(),
      ],
      verify: (_) {
        verify(
          () => rememberedAccounts.remember(
            email: 'jane@example.com',
            password: 'password123',
          ),
        ).called(1);
      },
    );

    blocTest<LoginStateService, LoginState>(
      'emits LoginFailure on error',
      setUp: () {
        when(
          () => identity.login(email: 'jane@example.com', password: 'wrong'),
        ).thenThrow(Exception('invalid credentials'));
      },
      build: () => LoginStateService(identity, rememberedAccounts),
      act: (service) =>
          service.submit(email: 'jane@example.com', password: 'wrong'),
      expect: () => [
        isA<LoginIdle>(),
        isA<LoginInProgress>(),
        isA<LoginFailure>(),
      ],
    );

    blocTest<LoginStateService, LoginState>(
      'loads remembered accounts on start',
      setUp: () {
        when(
          () => rememberedAccounts.getAll(),
        ).thenAnswer((_) async => [const RememberedAccount(email: 'jane@example.com')]);
      },
      build: () => LoginStateService(identity, rememberedAccounts),
      expect: () => [
        isA<LoginIdle>().having(
          (state) => state.rememberedAccounts.map((a) => a.email),
          'rememberedAccounts',
          ['jane@example.com'],
        ),
      ],
    );
  });
}
