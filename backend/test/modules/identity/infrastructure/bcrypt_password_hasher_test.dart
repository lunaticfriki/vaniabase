import 'package:backend/modules/identity/infrastructure/bcrypt_password_hasher.dart';
import 'package:core/modules/identity/domain/value_objects/password.dart';
import 'package:test/test.dart';

void main() {
  group('BcryptPasswordHasher', () {
    test('a hashed password verifies against the original candidate', () {
      final hasher = BcryptPasswordHasher();
      final password = Password.create('password123');

      final hash = hasher.hash(password);

      expect(hasher.verify('password123', hash), isTrue);
    });

    test('verify returns false for a non-matching candidate', () {
      final hasher = BcryptPasswordHasher();
      final hash = hasher.hash(Password.create('password123'));

      expect(hasher.verify('wrong-password', hash), isFalse);
    });

    test('hashing the same password twice produces different hashes', () {
      final hasher = BcryptPasswordHasher();
      final password = Password.create('password123');

      final first = hasher.hash(password);
      final second = hasher.hash(password);

      expect(first.value, isNot(equals(second.value)));
    });
  });
}
