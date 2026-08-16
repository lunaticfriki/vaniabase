import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/catalog_option_labels_util.dart';
import 'package:frontend/modules/catalog/application/formats_state_service.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/presentation/format_list/format_list_view.dart';
import 'package:go_router/go_router.dart';

class FormatListContainer extends StatefulWidget {
  const FormatListContainer({super.key});

  @override
  State<FormatListContainer> createState() => _FormatListContainerState();
}

class _FormatListContainerState extends State<FormatListContainer> {
  late final FormatsStateService _stateService;

  @override
  void initState() {
    super.initState();
    _stateService = FormatsStateService(
      getIt<ItemReadService>(),
      formatLabels.keys.toList(),
    );
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
      child: BlocBuilder<FormatsStateService, FormatsState>(
        builder: (context, state) => switch (state) {
          FormatsLoading() => const Center(child: CircularProgressIndicator()),
          FormatsError(:final message) => Center(child: Text(message)),
          FormatsLoaded(:final previewImageUrls) => FormatListView(
            previewImageUrls: previewImageUrls,
            onFormatTap: (format) => context.go('/formats/$format'),
          ),
        },
      ),
    );
  }
}
