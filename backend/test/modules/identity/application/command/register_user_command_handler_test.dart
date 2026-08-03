import 'package:backend/modules/identity/application/command/register_user_command.dart';
import 'package:backend/modules/identity/application/command/register_user_command_handler.dart';
import 'package:core/modules/identity/domain/errors/email_already_registered_error.dart';
import 'package:core/modules/identity/domain/errors/username_already_taken_error.dart';
import 'package:core/modules/identity/domain/repositories/user_repository.dart';
import 'package:core/modules/identity/domain/services/password_hasher.dart';
import 'package:core/modules/identity/domain/value_objects/email.dart';
import 'package:core/modules/identity/domain/value_objects/password.dart';
import 'package:core/modules/identity/domain/value_objects/password_hash.dart';
import 'package:core/modules/identity/domain/value_objects/username.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../../../core/test/modules/identity/domain/entities/user_mother.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockPasswordHasher extends Mock implements PasswordHasher {}

void main() {
  setUpAll(() {
    registerFallbackValue(UserMother.random());
    registerFallbackValue(Email.empty());
    registerFallbackValue(Username.empty());
    registerFallbackValue(Password.create('fallback1'));
  });

  group('RegisterUserCommandHandler', () {
    test('registers a new user and returns its id', () async {
      final repository = MockUserRepository();
      final hasher = MockPasswordHasher();
      when(() => repository.findByEmail(any())).thenAnswer((_) async => null);
      when(
        () => repository.findByUsername(any()),
      ).thenAnswer((_) async => null);
      when(
        () => hasher.hash(any()),
      ).thenReturn(PasswordHash.create('hashed-value'));
      when(() => repository.save(any())).thenAnswer((_) async {});

      final handler = RegisterUserCommandHandler(repository, hasher);
      final id = await handler.handle(
        const RegisterUserCommand(
          email: 'jane.doe@example.com',
          username: 'jane_doe',
          password: 'password123',
        ),
      );

      expect(id, isNotNull);
      verify(() => repository.save(any())).called(1);
    });

    test('throws when the email is already registered', () async {
      final repository = MockUserRepository();
      final hasher = MockPasswordHasher();
      when(
        () => repository.findByEmail(any()),
      ).thenAnswer((_) async => UserMother.random());

      final handler = RegisterUserCommandHandler(repository, hasher);

      expect(
        () => handler.handle(
          const RegisterUserCommand(
            email: 'jane.doe@example.com',
            username: 'jane_doe',
            password: 'password123',
          ),
        ),
        throwsA(isA<EmailAlreadyRegisteredError>()),
      );
    });

    test('throws when the username is already taken', () async {
      final repository = MockUserRepository();
      final hasher = MockPasswordHasher();
      when(() => repository.findByEmail(any())).thenAnswer((_) async => null);
      when(
        () => repository.findByUsername(any()),
      ).thenAnswer((_) async => UserMother.random());

      final handler = RegisterUserCommandHandler(repository, hasher);

      expect(
        () => handler.handle(
          const RegisterUserCommand(
            email: 'jane.doe@example.com',
            username: 'jane_doe',
            password: 'password123',
          ),
        ),
        throwsA(isA<UsernameAlreadyTakenError>()),
      );
    });

    test('propagates value object validation errors', () async {
      final repository = MockUserRepository();
      final hasher = MockPasswordHasher();

      final handler = RegisterUserCommandHandler(repository, hasher);

      expect(
        () => handler.handle(
          const RegisterUserCommand(
            email: 'not-an-email',
            username: 'jane_doe',
            password: 'password123',
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
