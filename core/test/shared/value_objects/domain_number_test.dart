import 'package:core/shared/value_objects/domain_number.dart';
import 'package:test/test.dart';

void main() {
  group('DomainNumber', () {
    test('create defaults to 2 decimal places', () {
      final number = DomainNumber.create(5);

      expect(number.formatted, '5.00');
    });

    test('an int and an equivalent double format identically', () {
      final fromInt = DomainNumber.create(5);
      final fromDouble = DomainNumber.create(5.0);

      expect(fromInt.formatted, fromDouble.formatted);
    });

    test('formats a double with the given decimal places', () {
      final number = DomainNumber.create(5.4);

      expect(number.formatted, '5.40');
    });

    test('create accepts a custom decimalPlaces', () {
      final number = DomainNumber.create(5.6, decimalPlaces: 0);

      expect(number.formatted, '6');
    });

    test('toString returns the formatted value', () {
      final number = DomainNumber.create(5.4);

      expect(number.toString(), number.formatted);
    });

    test('create throws for NaN', () {
      expect(
        () => DomainNumber.create(double.nan),
        throwsA(isA<InvalidDomainNumberError>()),
      );
    });

    test('create throws for infinite values', () {
      expect(
        () => DomainNumber.create(double.infinity),
        throwsA(isA<InvalidDomainNumberError>()),
      );
    });

    test('create throws for negative decimalPlaces', () {
      expect(
        () => DomainNumber.create(5, decimalPlaces: -1),
        throwsA(isA<InvalidDomainNumberError>()),
      );
    });

    test('create throws when decimalPlaces exceeds 10', () {
      expect(
        () => DomainNumber.create(5, decimalPlaces: 11),
        throwsA(isA<InvalidDomainNumberError>()),
      );
    });

    test('empty returns the neutral instance', () {
      final number = DomainNumber.empty();

      expect(number.value, 0);
      expect(number.formatted, '0.00');
    });

    test('equality is structural over value and decimalPlaces', () {
      expect(
        DomainNumber.create(5.4),
        equals(DomainNumber.create(5.4)),
      );
      expect(
        DomainNumber.create(5.4, decimalPlaces: 1),
        isNot(equals(DomainNumber.create(5.4, decimalPlaces: 2))),
      );
      expect(
        DomainNumber.create(5.4),
        isNot(equals(DomainNumber.create(5.5))),
      );
    });
  });
}
