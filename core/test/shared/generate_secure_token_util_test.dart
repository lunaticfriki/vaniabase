import 'package:core/shared/generate_secure_token_util.dart';
import 'package:test/test.dart';

final _hex64Pattern = RegExp(r'^[0-9a-f]{64}$');

void main() {
  group('generateSecureTokenUtil', () {
    test('produces a 64-character hex string', () {
      final token = generateSecureTokenUtil();

      expect(token, matches(_hex64Pattern));
    });

    test('produces a different value on each call', () {
      final first = generateSecureTokenUtil();
      final second = generateSecureTokenUtil();

      expect(first, isNot(equals(second)));
    });
  });
}
