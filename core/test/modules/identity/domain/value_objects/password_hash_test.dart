import 'package:core/modules/identity/domain/value_objects/password_hash.dart';
import 'package:test/test.dart';

void main() {
  group('PasswordHash', () {
    test('create accepts a non-empty hashed value', () {
      final hash = PasswordHash.create(r'$2b$12$abcdefghijklmnopqrstuv');

      expect(hash.value, r'$2b$12$abcdefghijklmnopqrstuv');
    });

    test('create throws when the value is empty', () {
      expect(
        () => PasswordHash.create(''),
        throwsA(isA<InvalidPasswordHashError>()),
      );
    });

    test('create throws when the value exceeds the max length', () {
      expect(
        () => PasswordHash.create('a' * 201),
        throwsA(isA<InvalidPasswordHashError>()),
      );
    });

    test('empty returns the neutral instance', () {
      expect(PasswordHash.empty().value, '');
    });

    test('equality is structural', () {
      expect(
        PasswordHash.create('hash-value'),
        equals(PasswordHash.create('hash-value')),
      );
    });
  });
}
