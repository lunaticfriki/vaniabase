import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:test/test.dart';

void main() {
  group('UserId', () {
    test('generate produces a valid v4 UUID', () {
      final id = UserId.generate();

      expect(
        id.value,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
    });

    test('generate produces a different id on each call', () {
      final first = UserId.generate();
      final second = UserId.generate();

      expect(first, isNot(equals(second)));
    });

    test('create accepts a valid v4 UUID string', () {
      const value = '3fa85f64-5717-4562-b3fc-2c963f66afa6';

      final id = UserId.create(value);

      expect(id.value, value);
    });

    test('create throws when the string is not a valid UUID', () {
      expect(
        () => UserId.create('not-a-uuid'),
        throwsA(isA<InvalidUserIdError>()),
      );
    });

    test('empty returns the nil UUID sentinel', () {
      final id = UserId.empty();

      expect(id.value, '00000000-0000-0000-0000-000000000000');
    });

    test('equality is structural', () {
      const value = '3fa85f64-5717-4562-b3fc-2c963f66afa6';

      expect(UserId.create(value), equals(UserId.create(value)));
    });
  });
}
