import 'package:core/modules/identity/domain/value_objects/password.dart';
import 'package:test/test.dart';

void main() {
  group('Password', () {
    test('create accepts a value with letters and digits, min 8 chars', () {
      final password = Password.create('abc12345');

      expect(password.value, 'abc12345');
    });

    test('create throws when shorter than 8 characters', () {
      expect(
        () => Password.create('abc123'),
        throwsA(isA<WeakPasswordError>()),
      );
    });

    test('create throws when longer than 128 characters', () {
      expect(
        () => Password.create('a1' * 65),
        throwsA(isA<WeakPasswordError>()),
      );
    });

    test('create throws when there is no digit', () {
      expect(
        () => Password.create('abcdefgh'),
        throwsA(isA<WeakPasswordError>()),
      );
    });

    test('create throws when there is no letter', () {
      expect(
        () => Password.create('12345678'),
        throwsA(isA<WeakPasswordError>()),
      );
    });

    test('equality is structural', () {
      expect(Password.create('abc12345'), equals(Password.create('abc12345')));
    });
  });
}
