import 'package:core/modules/identity/domain/value_objects/username.dart';
import 'package:test/test.dart';

void main() {
  group('Username', () {
    test('create accepts a valid username', () {
      final username = Username.create('jane_doe1');

      expect(username.value, 'jane_doe1');
    });

    test('create trims surrounding whitespace', () {
      final username = Username.create('  jane_doe  ');

      expect(username.value, 'jane_doe');
    });

    test('create throws when shorter than 3 characters', () {
      expect(
        () => Username.create('ab'),
        throwsA(isA<InvalidUsernameError>()),
      );
    });

    test('create throws when longer than 30 characters', () {
      expect(
        () => Username.create('a' * 31),
        throwsA(isA<InvalidUsernameError>()),
      );
    });

    test('create throws when it contains disallowed characters', () {
      expect(
        () => Username.create('jane doe!'),
        throwsA(isA<InvalidUsernameError>()),
      );
    });

    test('empty returns the neutral instance', () {
      expect(Username.empty().value, '');
    });

    test('equality is structural', () {
      expect(Username.create('jane_doe'), equals(Username.create('jane_doe')));
    });
  });
}
