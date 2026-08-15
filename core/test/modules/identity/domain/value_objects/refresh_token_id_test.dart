import 'package:core/modules/identity/domain/value_objects/refresh_token_id.dart';
import 'package:test/test.dart';

void main() {
  group('RefreshTokenId', () {
    test('generate produces a 64-character hex token', () {
      final id = RefreshTokenId.generate();

      expect(id.value, matches(RegExp(r'^[0-9a-f]{64}$')));
    });

    test('generate produces a different id on each call', () {
      final first = RefreshTokenId.generate();
      final second = RefreshTokenId.generate();

      expect(first, isNot(equals(second)));
    });

    test('create accepts a valid 64-character hex string', () {
      final value = 'a' * 64;

      final id = RefreshTokenId.create(value);

      expect(id.value, value);
    });

    test('create throws when the string is not 64 hex characters', () {
      expect(
        () => RefreshTokenId.create('not-a-token'),
        throwsA(isA<InvalidRefreshTokenIdError>()),
      );
    });

    test('empty returns the neutral instance', () {
      final id = RefreshTokenId.empty();

      expect(id.value, '0' * 64);
    });

    test('equality is structural', () {
      final value = 'b' * 64;

      expect(
          RefreshTokenId.create(value), equals(RefreshTokenId.create(value)));
    });
  });
}
