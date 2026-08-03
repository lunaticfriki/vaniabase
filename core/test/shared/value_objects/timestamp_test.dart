import 'package:core/shared/value_objects/timestamp.dart';
import 'package:test/test.dart';

void main() {
  group('Timestamp', () {
    test('create accepts a value that is not in the future', () {
      final value = DateTime(2020, 1, 1);

      final timestamp = Timestamp.create(value);

      expect(timestamp.value, value);
    });

    test('create throws when the value is in the future', () {
      final future = DateTime.now().add(const Duration(days: 1));

      expect(
        () => Timestamp.create(future),
        throwsA(isA<FutureTimestampError>()),
      );
    });

    test('now returns a timestamp close to the current time', () {
      final before = DateTime.now();

      final timestamp = Timestamp.now();

      final after = DateTime.now();
      expect(
        timestamp.value.isAfter(before) ||
            timestamp.value.isAtSameMomentAs(before),
        isTrue,
      );
      expect(
        timestamp.value.isBefore(after) ||
            timestamp.value.isAtSameMomentAs(after),
        isTrue,
      );
    });

    test('empty returns the epoch sentinel', () {
      final timestamp = Timestamp.empty();

      expect(timestamp.value, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('isBefore/isAfter compare two timestamps', () {
      final earlier = Timestamp.create(DateTime(2020, 1, 1));
      final later = Timestamp.create(DateTime(2021, 1, 1));

      expect(earlier.isBefore(later), isTrue);
      expect(later.isAfter(earlier), isTrue);
      expect(later.isBefore(earlier), isFalse);
    });

    test('at accepts a value in the future, unlike create', () {
      final future = DateTime.now().add(const Duration(days: 30));

      final timestamp = Timestamp.at(future);

      expect(timestamp.value, future);
    });

    test('at accepts a value in the past', () {
      final past = DateTime(2020, 1, 1);

      final timestamp = Timestamp.at(past);

      expect(timestamp.value, past);
    });

    test('equality is structural', () {
      final a = Timestamp.create(DateTime(2020, 1, 1));
      final b = Timestamp.create(DateTime(2020, 1, 1));
      final c = Timestamp.create(DateTime(2021, 1, 1));

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });
}
