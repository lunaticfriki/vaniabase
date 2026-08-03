import 'package:core/shared/generate_uuid_util.dart';
import 'package:test/test.dart';

final _uuidV4Pattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

void main() {
  group('generateUuidV4Util', () {
    test('produces a string matching the UUID v4 format', () {
      final uuid = generateUuidV4Util();

      expect(uuid, matches(_uuidV4Pattern));
    });

    test('produces a different value on each call', () {
      final first = generateUuidV4Util();
      final second = generateUuidV4Util();

      expect(first, isNot(equals(second)));
    });

    test('produces unique values across many calls', () {
      final uuids = List.generate(1000, (_) => generateUuidV4Util());

      expect(uuids.toSet(), hasLength(uuids.length));
    });
  });
}
