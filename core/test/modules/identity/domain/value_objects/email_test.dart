import 'package:core/modules/identity/domain/value_objects/email.dart';
import 'package:test/test.dart';

void main() {
  group('Email', () {
    test('create accepts a valid email', () {
      final email = Email.create('user@example.com');

      expect(email.value, 'user@example.com');
    });

    test('create trims surrounding whitespace', () {
      final email = Email.create('  user@example.com  ');

      expect(email.value, 'user@example.com');
    });

    test('create lowercases the value', () {
      final email = Email.create('User@Example.COM');

      expect(email.value, 'user@example.com');
    });

    test('create throws for a value with no @', () {
      expect(
        () => Email.create('not-an-email'),
        throwsA(isA<InvalidEmailError>()),
      );
    });

    test('create throws for a value with no domain', () {
      expect(
        () => Email.create('user@'),
        throwsA(isA<InvalidEmailError>()),
      );
    });

    test('empty returns the neutral instance', () {
      expect(Email.empty().value, '');
    });

    test('equality is structural', () {
      expect(Email.create('user@example.com'), equals(Email.create('user@example.com')));
    });
  });
}
