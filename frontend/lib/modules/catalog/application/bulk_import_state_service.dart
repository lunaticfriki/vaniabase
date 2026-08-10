import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/bulk_import_parser.dart';
import 'package:frontend/modules/catalog/application/bulk_import_state.dart';
import 'package:frontend/modules/catalog/application/item_write_service.dart';

class BulkImportStateService extends Cubit<BulkImportState> {
  BulkImportStateService(this._writeService) : super(const BulkImportIdle());

  final ItemWriteService _writeService;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx', 'ods', 'csv'],
    );
    if (result == null) return;
    final file = result.files.single;
    try {
      final bytes = await file.xFile.readAsBytes();
      handlePickedFile(bytes, file.name);
    } catch (_) {
      emit(const BulkImportError('Could not read the selected file.'));
    }
  }

  void handlePickedFile(Uint8List bytes, String fileName) {
    emit(const BulkImportParsing());
    try {
      final rows = parseBulkImportFile(bytes, fileName);
      if (rows.isEmpty) {
        emit(const BulkImportError('No data rows were found in the file.'));
        return;
      }
      emit(BulkImportPreview(fileName, rows));
    } on BulkImportParseException catch (error) {
      emit(BulkImportError(error.message));
    } catch (_) {
      emit(
        const BulkImportError(
          'Could not read this file. Make sure it is a valid .xlsx, .ods, or .csv file.',
        ),
      );
    }
  }

  Future<void> startImport() async {
    final current = state;
    if (current is! BulkImportPreview) return;
    final validRows = current.validRows;
    final failures = <ImportRowFailure>[];
    var succeeded = 0;

    emit(BulkImportImporting(validRows.length, 0));
    for (var i = 0; i < validRows.length; i++) {
      final row = validRows[i];
      try {
        await _writeService.create(
          title: row.title,
          creator: row.creator,
          publisher: row.publisher,
          category: row.category!,
          format: row.format!,
          tags: row.tags.isEmpty ? null : row.tags,
          topic: row.topic.isEmpty ? null : row.topic,
          year: row.year,
          description: row.description.isEmpty ? null : row.description,
          language: row.language.isEmpty ? null : row.language,
          imageUrl: row.imageUrl.isEmpty ? null : row.imageUrl,
          completed: row.completed,
          reference: row.reference.isEmpty ? null : row.reference,
        );
        succeeded++;
      } catch (error) {
        failures.add(
          ImportRowFailure(rowNumber: row.rowNumber, title: row.title, message: error.toString()),
        );
      }
      emit(BulkImportImporting(validRows.length, i + 1));
    }

    emit(BulkImportDone(succeeded, failures));
  }

  void reset() => emit(const BulkImportIdle());
}
