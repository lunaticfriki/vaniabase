import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:frontend/modules/catalog/application/bulk_import_row.dart';
import 'package:frontend/modules/catalog/application/catalog_option_labels_util.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

final _languageCodePattern = RegExp(r'^[a-zA-Z]{2}$');
final _nonAlphaNumericPattern = RegExp(r'[^a-z0-9]');

const _headerAliasToField = {
  'title': 'title',
  'creator': 'creator',
  'creators': 'creator',
  'author': 'creator',
  'authors': 'creator',
  'publisher': 'publisher',
  'category': 'category',
  'format': 'format',
  'tag': 'tags',
  'tags': 'tags',
  'topic': 'topic',
  'year': 'year',
  'publicationyear': 'year',
  'description': 'description',
  'language': 'language',
  'imageurl': 'imageUrl',
  'image': 'imageUrl',
  'cover': 'imageUrl',
  'coverurl': 'imageUrl',
  'completed': 'completed',
  'reference': 'reference',
  'isbn': 'reference',
};

const _requiredFields = ['title', 'creator', 'publisher', 'category', 'format'];

class BulkImportParseException implements Exception {
  const BulkImportParseException(this.message);

  final String message;
}

List<BulkImportRow> parseBulkImportFile(Uint8List bytes, String fileName) {
  final extension = fileName.toLowerCase().split('.').last;
  final List<List<dynamic>> rawRows;
  if (extension == 'csv') {
    final text = utf8.decode(bytes, allowMalformed: true);
    rawRows = csv.decode(text);
  } else if (extension == 'xlsx' || extension == 'ods') {
    final decoder = SpreadsheetDecoder.decodeBytes(bytes);
    if (decoder.tables.isEmpty) {
      throw const BulkImportParseException('The file has no sheets.');
    }
    rawRows = decoder.tables[decoder.tables.keys.first]!.rows;
  } else {
    throw BulkImportParseException(
      'Unsupported file type ".$extension". Use .xlsx, .ods, or .csv.',
    );
  }

  if (rawRows.isEmpty) {
    throw const BulkImportParseException('The file is empty.');
  }

  final headers = rawRows.first
      .map((cell) => _normalize(cell?.toString() ?? ''))
      .toList();
  final fieldColumns = <String, int>{};
  for (var i = 0; i < headers.length; i++) {
    final field = _headerAliasToField[headers[i]];
    if (field != null) fieldColumns[field] = i;
  }

  final missingRequired = _requiredFields
      .where((field) => !fieldColumns.containsKey(field))
      .toList();
  if (missingRequired.isNotEmpty) {
    throw BulkImportParseException(
      'Missing required column(s): ${missingRequired.join(', ')}.',
    );
  }

  String cellText(List<dynamic> row, String field) {
    final index = fieldColumns[field];
    if (index == null || index >= row.length) return '';
    return row[index]?.toString().trim() ?? '';
  }

  dynamic cellRaw(List<dynamic> row, String field) {
    final index = fieldColumns[field];
    if (index == null || index >= row.length) return null;
    return row[index];
  }

  final rows = <BulkImportRow>[];
  for (var i = 1; i < rawRows.length; i++) {
    final row = rawRows[i];
    if (row.every((cell) => (cell?.toString().trim() ?? '').isEmpty)) continue;

    final errors = <String>[];

    final title = cellText(row, 'title');
    if (title.isEmpty) {
      errors.add('Title is required');
    } else if (title.length > 200) {
      errors.add('Title must be at most 200 characters');
    }

    final creator = _parseList(cellText(row, 'creator'));
    if (creator.isEmpty) errors.add('At least one creator is required');

    final publisher = cellText(row, 'publisher');
    if (publisher.isEmpty) {
      errors.add('Publisher is required');
    } else if (publisher.length > 150) {
      errors.add('Publisher must be at most 150 characters');
    }

    final categoryRaw = cellText(row, 'category');
    final category = categoryRaw.isEmpty
        ? null
        : _resolveOption(categoryRaw, categoryLabels);
    if (categoryRaw.isEmpty) {
      errors.add('Category is required');
    } else if (category == null) {
      errors.add('Unknown category "$categoryRaw"');
    }

    final formatRaw = _parseList(cellText(row, 'format'));
    final format = formatRaw
        .map((raw) => _resolveOption(raw, formatLabels))
        .toList();
    if (formatRaw.isEmpty) {
      errors.add('Format is required');
    } else if (format.any((resolved) => resolved == null)) {
      final unknown = [
        for (var i = 0; i < formatRaw.length; i++)
          if (format[i] == null) formatRaw[i],
      ];
      errors.add('Unknown format "${unknown.join(', ')}"');
    }

    final tags = _parseList(cellText(row, 'tags'));
    if (tags.length > 10) errors.add('At most 10 tags are allowed');
    if (tags.any((tag) => tag.length > 30))
      errors.add('Each tag must be at most 30 characters');

    final topic = cellText(row, 'topic');
    if (topic.length > 100) errors.add('Topic must be at most 100 characters');

    final yearText = cellText(row, 'year');
    final year = _parseYear(cellRaw(row, 'year'));
    final currentYear = DateTime.now().year;
    if (yearText.isNotEmpty &&
        (year == null || year < 1000 || year > currentYear)) {
      errors.add('Year must be between 1000 and $currentYear');
    }

    final description = cellText(row, 'description');
    if (description.length > 2000)
      errors.add('Description must be at most 2000 characters');

    final language = _parseList(
      cellText(row, 'language'),
    ).map((raw) => raw.toLowerCase()).toList();
    if (language.any((raw) => !_languageCodePattern.hasMatch(raw))) {
      errors.add('Each language must be a 2-letter code');
    }

    final imageUrl = cellText(row, 'imageUrl');
    if (imageUrl.isNotEmpty && !_isValidImageUrl(imageUrl)) {
      errors.add('Image URL must be a valid http(s) URL');
    }

    final reference = cellText(row, 'reference');
    if (reference.length > 50)
      errors.add('Reference must be at most 50 characters');

    rows.add(
      BulkImportRow(
        rowNumber: i + 1,
        title: title,
        creator: creator,
        publisher: publisher,
        category: category,
        format: format.whereType<String>().toList(),
        tags: tags,
        topic: topic,
        year: year,
        description: description,
        language: language,
        imageUrl: imageUrl,
        completed: _parseBool(cellRaw(row, 'completed')),
        reference: reference,
        errors: errors,
      ),
    );
  }

  return rows;
}

String _normalize(String raw) =>
    raw.toLowerCase().replaceAll(_nonAlphaNumericPattern, '');

String? _resolveOption(String raw, Map<String, String> labels) {
  final normalized = _normalize(raw);
  if (normalized.isEmpty) return null;
  for (final entry in labels.entries) {
    if (_normalize(entry.key) == normalized ||
        _normalize(entry.value) == normalized) {
      return entry.key;
    }
  }
  return null;
}

List<String> _parseList(String value) {
  return value
      .split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
}

int? _parseYear(dynamic raw) {
  if (raw == null) return null;
  if (raw is num) return raw.toInt();
  final text = raw.toString().trim();
  if (text.isEmpty) return null;
  return int.tryParse(text);
}

bool _parseBool(dynamic raw) {
  if (raw is bool) return raw;
  final text = raw?.toString().trim().toLowerCase() ?? '';
  return text == 'true' ||
      text == 'yes' ||
      text == '1' ||
      text == 'x' ||
      text == 'y';
}

bool _isValidImageUrl(String value) {
  final uri = Uri.tryParse(value);
  return uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty;
}
