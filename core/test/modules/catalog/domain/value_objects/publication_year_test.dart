import 'package:core/modules/catalog/domain/value_objects/publication_year.dart';
import 'package:test/test.dart';

void main() {
  group('PublicationYear', () {
    test('create accepts a value within range', () {
      final year = PublicationYear.create(1999);

      expect(year.value, 1999);
    });

    test('create accepts the current year', () {
      final currentYear = DateTime.now().year;

      final year = PublicationYear.create(currentYear);

      expect(year.value, currentYear);
    });

    test('create throws when before 1000', () {
      expect(
        () => PublicationYear.create(999),
        throwsA(isA<InvalidPublicationYearError>()),
      );
    });

    test('create throws when after the current year', () {
      final nextYear = DateTime.now().year + 1;

      expect(
        () => PublicationYear.create(nextYear),
        throwsA(isA<InvalidPublicationYearError>()),
      );
    });

    test('empty returns the neutral instance', () {
      expect(PublicationYear.empty().value, 0);
    });

    test('equality is structural', () {
      expect(
        PublicationYear.create(1999),
        equals(PublicationYear.create(1999)),
      );
    });
  });
}
