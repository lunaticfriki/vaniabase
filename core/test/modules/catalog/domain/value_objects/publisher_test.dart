import 'package:core/modules/catalog/domain/value_objects/publisher.dart';
import 'package:test/test.dart';

void main() {
  group('Publisher', () {
    test('create accepts a valid publisher', () {
      final publisher = Publisher.create('Addison-Wesley');

      expect(publisher.value, 'Addison-Wesley');
    });

    test('create trims surrounding whitespace', () {
      final publisher = Publisher.create('  Marvel  ');

      expect(publisher.value, 'Marvel');
    });

    test('create throws when empty after trim', () {
      expect(
        () => Publisher.create('   '),
        throwsA(isA<InvalidPublisherError>()),
      );
    });

    test('create throws when longer than 150 characters', () {
      expect(
        () => Publisher.create('a' * 151),
        throwsA(isA<InvalidPublisherError>()),
      );
    });

    test('empty returns the neutral instance', () {
      expect(Publisher.empty().value, '');
    });

    test('equality is structural', () {
      expect(Publisher.create('Marvel'), equals(Publisher.create('Marvel')));
    });
  });
}
