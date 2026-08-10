import 'package:frontend/modules/catalog/application/bulk_import_row.dart';

class ImportRowFailure {
  const ImportRowFailure({required this.rowNumber, required this.title, required this.message});

  final int rowNumber;
  final String title;
  final String message;
}

sealed class BulkImportState {
  const BulkImportState();
}

class BulkImportIdle extends BulkImportState {
  const BulkImportIdle();
}

class BulkImportParsing extends BulkImportState {
  const BulkImportParsing();
}

class BulkImportPreview extends BulkImportState {
  const BulkImportPreview(this.fileName, this.rows);

  final String fileName;
  final List<BulkImportRow> rows;

  List<BulkImportRow> get validRows => rows.where((row) => row.isValid).toList();

  int get validCount => validRows.length;

  int get invalidCount => rows.length - validCount;
}

class BulkImportImporting extends BulkImportState {
  const BulkImportImporting(this.total, this.completed);

  final int total;
  final int completed;
}

class BulkImportDone extends BulkImportState {
  const BulkImportDone(this.succeeded, this.failures);

  final int succeeded;
  final List<ImportRowFailure> failures;
}

class BulkImportError extends BulkImportState {
  const BulkImportError(this.message);

  final String message;
}
