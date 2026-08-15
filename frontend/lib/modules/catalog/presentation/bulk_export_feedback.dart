import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/bulk_export_service.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';

/// Exports [items] to CSV, showing a snackbar with the outcome. Shared by
/// every page that offers an "Export" action on its currently displayed list.
Future<void> exportItemsWithFeedback(
  BuildContext context,
  List<ItemReadModel> items,
  String scope,
) async {
  final messenger = ScaffoldMessenger.of(context);
  if (items.isEmpty) {
    messenger.showSnackBar(
      const SnackBar(content: Text('No items to export.')),
    );
    return;
  }
  try {
    final exported = await exportItemsToCsvFile(items, scope: scope);
    if (!exported) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Exported ${items.length} item${items.length == 1 ? '' : 's'}.',
        ),
      ),
    );
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not export the file.')),
    );
  }
}
