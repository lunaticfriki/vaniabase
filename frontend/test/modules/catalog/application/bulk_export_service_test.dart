import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/modules/catalog/application/bulk_export_service.dart';
import 'package:frontend/modules/catalog/application/bulk_import_parser.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';

ItemReadModel _item({
  String title = 'Dune',
  List<String> creator = const ['Frank Herbert'],
  String publisher = 'Chilton Books',
  String category = 'book',
  List<String> format = const ['hardcover'],
  List<String> tags = const ['sci-fi', 'classic'],
  String topic = 'Science Fiction',
  int year = 1965,
  String description = 'A desert planet epic',
  List<String> language = const ['en'],
  String imageUrl = 'https://example.com/dune.jpg',
  bool completed = true,
  String reference = 'ISBN-1',
}) {
  final now = DateTime.now();
  return ItemReadModel(
    id: 'id',
    ownerId: 'owner',
    title: title,
    creator: creator,
    publisher: publisher,
    category: category,
    format: format,
    tags: tags,
    topic: topic,
    year: year,
    description: description,
    language: language,
    imageUrl: imageUrl,
    completed: completed,
    reference: reference,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('buildBulkExportCsvBytes', () {
    test('writes a header row matching the bulk import column layout', () {
      final bytes = buildBulkExportCsvBytes(const []);

      // UTF-8 BOM, so Excel detects the encoding correctly.
      expect(bytes.take(3), [0xEF, 0xBB, 0xBF]);
      expect(utf8.decode(bytes), contains(bulkExportHeaders.join(',')));
    });

    test('round-trips through the bulk import parser', () {
      final items = [
        _item(),
        _item(title: 'Neuromancer', completed: false, tags: const []),
      ];

      final bytes = buildBulkExportCsvBytes(items);
      final rows = parseBulkImportFile(bytes, 'export.csv');

      expect(rows, hasLength(2));
      expect(rows.every((row) => row.isValid), isTrue);

      final dune = rows.first;
      expect(dune.title, 'Dune');
      expect(dune.creator, ['Frank Herbert']);
      expect(dune.publisher, 'Chilton Books');
      expect(dune.category, 'book');
      expect(dune.format, ['hardcover']);
      expect(dune.tags, ['sci-fi', 'classic']);
      expect(dune.topic, 'Science Fiction');
      expect(dune.year, 1965);
      expect(dune.description, 'A desert planet epic');
      expect(dune.language, ['en']);
      expect(dune.imageUrl, 'https://example.com/dune.jpg');
      expect(dune.completed, isTrue);
      expect(dune.reference, 'ISBN-1');

      expect(rows.last.title, 'Neuromancer');
      expect(rows.last.completed, isFalse);
      expect(rows.last.tags, isEmpty);
    });

    test('round-trips an item with multiple formats and languages', () {
      final items = [
        _item(format: const ['dvd', 'bluRay'], language: const ['en', 'fr']),
      ];

      final bytes = buildBulkExportCsvBytes(items);
      final rows = parseBulkImportFile(bytes, 'export.csv');

      expect(rows.single.isValid, isTrue);
      expect(rows.single.format, ['dvd', 'bluRay']);
      expect(rows.single.language, ['en', 'fr']);
    });

    test('omits an unset year rather than writing 0', () {
      final bytes = buildBulkExportCsvBytes([_item(year: 0)]);
      final rows = parseBulkImportFile(bytes, 'export.csv');

      expect(rows.single.year, isNull);
    });
  });

  group('buildBulkExportFileName', () {
    test('slugifies the scope and appends a .csv extension', () {
      final fileName = buildBulkExportFileName('Complete collection');

      expect(fileName, startsWith('vaniabase-complete-collection-'));
      expect(fileName, endsWith('.csv'));
    });
  });
}
