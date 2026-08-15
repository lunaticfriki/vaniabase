import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';

const bulkExportHeaders = [
  'title',
  'creator',
  'publisher',
  'category',
  'format',
  'tags',
  'topic',
  'year',
  'description',
  'language',
  'imageUrl',
  'completed',
  'reference',
];

final _exportCsv = Csv(addBom: true);

/// Builds the export bytes in the same column layout the bulk importer
/// reads, so an exported file can be re-imported without remapping.
Uint8List buildBulkExportCsvBytes(List<ItemReadModel> items) {
  final rows = <List<dynamic>>[
    bulkExportHeaders,
    for (final item in items)
      [
        item.title,
        item.creator.join(', '),
        item.publisher,
        item.category,
        item.format.join(', '),
        item.tags.join(', '),
        item.topic,
        item.year > 0 ? item.year : '',
        item.description,
        item.language.join(', '),
        item.imageUrl,
        item.completed ? 'true' : 'false',
        item.reference,
      ],
  ];
  return Uint8List.fromList(utf8.encode(_exportCsv.encode(rows)));
}

String buildBulkExportFileName(String scope) {
  final slug = scope
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  final now = DateTime.now();
  final stamp =
      '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
  return 'vaniabase-$slug-$stamp.csv';
}

/// Opens a save dialog (or triggers a browser download on web) with the
/// items encoded as CSV. Returns whether the file was actually written.
Future<bool> exportItemsToCsvFile(
  List<ItemReadModel> items, {
  required String scope,
}) async {
  final bytes = buildBulkExportCsvBytes(items);
  final savedPath = await FilePicker.platform.saveFile(
    dialogTitle: 'Export collection',
    fileName: buildBulkExportFileName(scope),
    type: FileType.custom,
    allowedExtensions: const ['csv'],
    bytes: bytes,
  );
  return savedPath != null || kIsWeb;
}
