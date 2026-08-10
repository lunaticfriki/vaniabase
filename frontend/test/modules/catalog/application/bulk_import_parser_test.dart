import 'dart:convert';
import 'dart:typed_data';

import 'package:frontend/modules/catalog/application/bulk_import_parser.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _csvBytes(String csv) => Uint8List.fromList(utf8.encode(csv));

void main() {
  group('parseBulkImportFile', () {
    test('parses valid rows from a CSV file', () {
      const csv =
          'title,creator,publisher,category,format,tags,topic,year,description,language,imageUrl,completed,reference\n'
          'Dune,"Frank Herbert",Chilton Books,book,hardcover,"sci-fi, classic",Science Fiction,1965,'
          'A desert planet epic,en,https://example.com/dune.jpg,true,ISBN-1\n';

      final rows = parseBulkImportFile(_csvBytes(csv), 'items.csv');

      expect(rows, hasLength(1));
      final row = rows.single;
      expect(row.isValid, isTrue);
      expect(row.rowNumber, 2);
      expect(row.title, 'Dune');
      expect(row.creator, ['Frank Herbert']);
      expect(row.publisher, 'Chilton Books');
      expect(row.category, 'book');
      expect(row.format, 'hardcover');
      expect(row.tags, ['sci-fi', 'classic']);
      expect(row.topic, 'Science Fiction');
      expect(row.year, 1965);
      expect(row.language, 'en');
      expect(row.imageUrl, 'https://example.com/dune.jpg');
      expect(row.completed, isTrue);
      expect(row.reference, 'ISBN-1');
    });

    test('resolves category and format from their human-readable labels', () {
      const csv =
          'title,creator,publisher,category,format\n'
          'Blade Runner,Ridley Scott,Warner,Movie,Blu-ray\n';

      final rows = parseBulkImportFile(_csvBytes(csv), 'items.csv');

      expect(rows.single.category, 'movie');
      expect(rows.single.format, 'bluRay');
    });

    test('flags rows missing required fields', () {
      const csv =
          'title,creator,publisher,category,format\n'
          ',Frank Herbert,Chilton Books,book,hardcover\n';

      final rows = parseBulkImportFile(_csvBytes(csv), 'items.csv');

      expect(rows.single.isValid, isFalse);
      expect(rows.single.errors, contains('Title is required'));
    });

    test('flags an unknown category or format', () {
      const csv =
          'title,creator,publisher,category,format\n'
          'Dune,Frank Herbert,Chilton Books,novel,hardcover\n';

      final rows = parseBulkImportFile(_csvBytes(csv), 'items.csv');

      expect(rows.single.isValid, isFalse);
      expect(rows.single.errors, contains('Unknown category "novel"'));
    });

    test('flags a year outside the valid range', () {
      const csv =
          'title,creator,publisher,category,format,year\n'
          'Dune,Frank Herbert,Chilton Books,book,hardcover,999\n';

      final rows = parseBulkImportFile(_csvBytes(csv), 'items.csv');

      expect(rows.single.isValid, isFalse);
      expect(rows.single.errors, contains('Year must be between 1000 and ${DateTime.now().year}'));
    });

    test('flags a language that is not a 2-letter code', () {
      const csv =
          'title,creator,publisher,category,format,language\n'
          'Dune,Frank Herbert,Chilton Books,book,hardcover,english\n';

      final rows = parseBulkImportFile(_csvBytes(csv), 'items.csv');

      expect(rows.single.isValid, isFalse);
      expect(rows.single.errors, contains('Language must be a 2-letter code'));
    });

    test('flags an image URL that is not http(s)', () {
      const csv =
          'title,creator,publisher,category,format,imageUrl\n'
          'Dune,Frank Herbert,Chilton Books,book,hardcover,not-a-url\n';

      final rows = parseBulkImportFile(_csvBytes(csv), 'items.csv');

      expect(rows.single.isValid, isFalse);
      expect(rows.single.errors, contains('Image URL must be a valid http(s) URL'));
    });

    test('skips fully blank rows', () {
      const csv =
          'title,creator,publisher,category,format\n'
          'Dune,Frank Herbert,Chilton Books,book,hardcover\n'
          ',,,,\n'
          'Foundation,Isaac Asimov,Gnome Press,book,hardcover\n';

      final rows = parseBulkImportFile(_csvBytes(csv), 'items.csv');

      expect(rows, hasLength(2));
      expect(rows.map((row) => row.title), ['Dune', 'Foundation']);
    });

    test('throws when required columns are missing', () {
      const csv = 'title,creator\nDune,Frank Herbert\n';

      expect(
        () => parseBulkImportFile(_csvBytes(csv), 'items.csv'),
        throwsA(isA<BulkImportParseException>()),
      );
    });

    test('throws for an unsupported file extension', () {
      expect(
        () => parseBulkImportFile(_csvBytes('title\nDune\n'), 'items.txt'),
        throwsA(isA<BulkImportParseException>()),
      );
    });

    test('throws for an empty file', () {
      expect(
        () => parseBulkImportFile(_csvBytes(''), 'items.csv'),
        throwsA(isA<BulkImportParseException>()),
      );
    });
  });
}
