import 'package:core/modules/catalog/domain/value_objects/reference.dart';
import 'package:test/test.dart';

void main() {
  group('Reference', () {
    test('create accepts a valid reference', () {
      final reference = Reference.create('978-0132350884');

      expect(reference.value, '978-0132350884');
    });

    test('create trims surrounding whitespace', () {
      final reference = Reference.create('  ABC123  ');

      expect(reference.value, 'ABC123');
    });

    test('create throws when empty after trim', () {
      expect(
          () => Reference.create('   '), throwsA(isA<InvalidReferenceError>()));
    });

    test('create throws when longer than 50 characters', () {
      expect(() => Reference.create('a' * 51),
          throwsA(isA<InvalidReferenceError>()));
    });

    test('empty returns the neutral instance', () {
      expect(Reference.empty().value, '');
    });

    test('equality is structural', () {
      expect(Reference.create('ABC123'), equals(Reference.create('ABC123')));
    });
  });
}
