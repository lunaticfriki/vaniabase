import 'package:core/modules/catalog/domain/value_objects/topic.dart';
import 'package:test/test.dart';

void main() {
  group('Topic', () {
    test('create accepts a valid topic', () {
      final topic = Topic.create('Software Engineering');

      expect(topic.value, 'Software Engineering');
    });

    test('create trims surrounding whitespace', () {
      final topic = Topic.create('  Jazz  ');

      expect(topic.value, 'Jazz');
    });

    test('create throws when empty after trim', () {
      expect(() => Topic.create('   '), throwsA(isA<InvalidTopicError>()));
    });

    test('create throws when longer than 100 characters', () {
      expect(
        () => Topic.create('a' * 101),
        throwsA(isA<InvalidTopicError>()),
      );
    });

    test('empty returns the neutral instance', () {
      expect(Topic.empty().value, '');
    });

    test('equality is structural', () {
      expect(Topic.create('Jazz'), equals(Topic.create('Jazz')));
    });
  });
}
