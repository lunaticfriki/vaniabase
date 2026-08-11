import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/bulk_import_row.dart';
import 'package:frontend/modules/catalog/application/bulk_import_state_service.dart';
import 'package:pixelarticons/pixel.dart';

class BulkImportView extends StatelessWidget {
  const BulkImportView({
    required this.state,
    required this.onPickFile,
    required this.onStartImport,
    required this.onReset,
    required this.onDone,
    super.key,
  });

  final BulkImportState state;
  final VoidCallback onPickFile;
  final VoidCallback onStartImport;
  final VoidCallback onReset;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Import from spreadsheet',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              switch (state) {
                BulkImportIdle() => _IdleBody(onPickFile: onPickFile),
                BulkImportParsing() => const _ParsingBody(),
                BulkImportPreview() => _PreviewBody(
                  state: state as BulkImportPreview,
                  onStartImport: onStartImport,
                  onReset: onReset,
                ),
                BulkImportImporting() => _ImportingBody(
                  state: state as BulkImportImporting,
                ),
                BulkImportDone() => _DoneBody(
                  state: state as BulkImportDone,
                  onDone: onDone,
                  onReset: onReset,
                ),
                BulkImportError(:final message) => _ErrorBody(
                  message: message,
                  onReset: onReset,
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

const _expectedColumns =
    'title, creator, publisher, category, format, tags, topic, year, '
    'description, language, imageUrl, completed, reference';

class _IdleBody extends StatelessWidget {
  const _IdleBody({required this.onPickFile});

  final VoidCallback onPickFile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Upload a spreadsheet (.xlsx, .ods, or .csv) with one row per item. '
          'The first row must be a header row with these column names:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          _expectedColumns,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Required: title, creator, publisher, category, format. '
          'Creator and tags accept multiple, comma-separated values in a single cell. '
          'imageUrl can point to an existing image — you can always attach an image '
          'file afterwards from each item\'s edit screen.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onPickFile,
          icon: const Icon(Pixel.upload),
          label: const Text('Choose file'),
        ),
      ],
    );
  }
}

class _ParsingBody extends StatelessWidget {
  const _ParsingBody();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Reading file...'),
        ],
      ),
    );
  }
}

class _PreviewBody extends StatelessWidget {
  const _PreviewBody({
    required this.state,
    required this.onStartImport,
    required this.onReset,
  });

  final BulkImportPreview state;
  final VoidCallback onStartImport;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(state.fileName, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          '${state.validCount} of ${state.rows.length} row${state.rows.length == 1 ? '' : 's'} '
          'ready to import'
          '${state.invalidCount > 0 ? ' — ${state.invalidCount} need fixing' : ''}.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 360),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: state.rows.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) => _RowTile(row: state.rows[index]),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            FilledButton(
              onPressed: state.validCount == 0 ? null : onStartImport,
              child: Text(
                'Import ${state.validCount} item${state.validCount == 1 ? '' : 's'}',
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: onReset,
              child: const Text('Choose a different file'),
            ),
          ],
        ),
        if (state.validCount == 0) ...[
          const SizedBox(height: 8),
          Text(
            'Fix the errors below and re-upload the file.',
            style: TextStyle(color: colorScheme.error),
          ),
        ],
      ],
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({required this.row});

  final BulkImportRow row;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      leading: Icon(
        row.isValid ? Pixel.check : Pixel.close,
        color: row.isValid ? colorScheme.primary : colorScheme.error,
      ),
      title: Text(row.title.isEmpty ? '(untitled)' : row.title),
      subtitle: row.isValid
          ? null
          : Text(
              'Row ${row.rowNumber}: ${row.errors.join('; ')}',
              style: TextStyle(color: colorScheme.error),
            ),
    );
  }
}

class _ImportingBody extends StatelessWidget {
  const _ImportingBody({required this.state});

  final BulkImportImporting state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Importing ${state.completed} of ${state.total}...'),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: state.total == 0 ? null : state.completed / state.total,
        ),
      ],
    );
  }
}

class _DoneBody extends StatelessWidget {
  const _DoneBody({
    required this.state,
    required this.onDone,
    required this.onReset,
  });

  final BulkImportDone state;
  final VoidCallback onDone;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Imported ${state.succeeded} item${state.succeeded == 1 ? '' : 's'}.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (state.failures.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            '${state.failures.length} row${state.failures.length == 1 ? '' : 's'} failed to import:',
            style: TextStyle(color: colorScheme.error),
          ),
          const SizedBox(height: 4),
          for (final failure in state.failures)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Row ${failure.rowNumber} (${failure.title.isEmpty ? 'untitled' : failure.title}): '
                '${failure.message}',
                style: TextStyle(color: colorScheme.error),
              ),
            ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            FilledButton(onPressed: onDone, child: const Text('Done')),
            const SizedBox(width: 12),
            TextButton(
              onPressed: onReset,
              child: const Text('Import another file'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onReset});

  final String message;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: onReset, child: const Text('Try again')),
      ],
    );
  }
}
