import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/modules/catalog/infrastructure/acl/item_mapper.dart';

void main() {
  group('ItemMapper.toReadModel', () {
    test('maps a full Firestore document', () {
      final createdAt = DateTime(2026, 1, 1);
      final updatedAt = DateTime(2026, 1, 2);

      final model = ItemMapper.toReadModel('item-1', {
        'owner_id': 'user-1',
        'title': 'Dune',
        'creator': ['Frank Herbert'],
        'publisher': 'Chilton Books',
        'category': 'book',
        'format': 'paperback',
        'tags': ['sci-fi'],
        'topic': 'space opera',
        'year': 1965,
        'description': 'A desert planet.',
        'language': 'en',
        'image_url': 'https://example.com/dune.jpg',
        'completed': true,
        'reference': '978-0441172719',
        'created_at': Timestamp.fromDate(createdAt),
        'updated_at': Timestamp.fromDate(updatedAt),
      });

      expect(model.id, 'item-1');
      expect(model.ownerId, 'user-1');
      expect(model.title, 'Dune');
      expect(model.creator, ['Frank Herbert']);
      expect(model.category, 'book');
      expect(model.year, 1965);
      expect(model.completed, isTrue);
      expect(model.reference, '978-0441172719');
      expect(model.createdAt, createdAt);
      expect(model.updatedAt, updatedAt);
    });

    test(
      'reads a legacy single-string format/language as a single-item list',
      () {
        final now = DateTime(2026, 1, 1);

        final model = ItemMapper.toReadModel('item-legacy', {
          'owner_id': 'user-1',
          'title': 'Dune',
          'publisher': 'Chilton Books',
          'category': 'book',
          'format': 'dvd',
          'language': 'en',
          'created_at': Timestamp.fromDate(now),
          'updated_at': Timestamp.fromDate(now),
        });

        expect(model.format, ['dvd']);
        expect(model.language, ['en']);
      },
    );

    test('reads a format/language array as-is', () {
      final now = DateTime(2026, 1, 1);

      final model = ItemMapper.toReadModel('item-array', {
        'owner_id': 'user-1',
        'title': 'Blade Runner',
        'publisher': 'Warner',
        'category': 'movie',
        'format': ['dvd', 'bluRay'],
        'language': ['en', 'fr'],
        'created_at': Timestamp.fromDate(now),
        'updated_at': Timestamp.fromDate(now),
      });

      expect(model.format, ['dvd', 'bluRay']);
      expect(model.language, ['en', 'fr']);
    });

    test('defaults missing optional fields', () {
      final now = DateTime(2026, 1, 1);

      final model = ItemMapper.toReadModel('item-2', {
        'owner_id': 'user-1',
        'title': 'Untitled',
        'publisher': 'Self',
        'category': 'book',
        'format': 'ebook',
        'created_at': Timestamp.fromDate(now),
        'updated_at': Timestamp.fromDate(now),
      });

      expect(model.creator, isEmpty);
      expect(model.tags, isEmpty);
      expect(model.topic, '');
      expect(model.year, 0);
      expect(model.description, '');
      expect(model.language, isEmpty);
      expect(model.imageUrl, '');
      expect(model.completed, isFalse);
      expect(model.reference, '');
    });
  });
}
