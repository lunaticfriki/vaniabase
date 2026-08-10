import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/bulk_import_state.dart';
import 'package:frontend/modules/catalog/application/bulk_import_state_service.dart';
import 'package:frontend/modules/catalog/application/item_write_service.dart';
import 'package:frontend/modules/catalog/presentation/bulk_import/bulk_import_view.dart';
import 'package:go_router/go_router.dart';

class BulkImportContainer extends StatefulWidget {
  const BulkImportContainer({super.key});

  @override
  State<BulkImportContainer> createState() => _BulkImportContainerState();
}

class _BulkImportContainerState extends State<BulkImportContainer> {
  late final BulkImportStateService _stateService;

  @override
  void initState() {
    super.initState();
    _stateService = BulkImportStateService(getIt<ItemWriteService>());
  }

  @override
  void dispose() {
    _stateService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _stateService,
      child: BlocBuilder<BulkImportStateService, BulkImportState>(
        builder: (context, state) => BulkImportView(
          state: state,
          onPickFile: () => context.read<BulkImportStateService>().pickFile(),
          onStartImport: () => context.read<BulkImportStateService>().startImport(),
          onReset: () => context.read<BulkImportStateService>().reset(),
          onDone: () => context.go('/items'),
        ),
      ),
    );
  }
}
