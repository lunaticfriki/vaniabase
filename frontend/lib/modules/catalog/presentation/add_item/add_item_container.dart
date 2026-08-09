import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/add_item_state.dart';
import 'package:frontend/modules/catalog/application/add_item_state_service.dart';
import 'package:frontend/modules/catalog/application/item_write_service.dart';
import 'package:frontend/modules/catalog/presentation/item_form/item_form_view.dart';
import 'package:go_router/go_router.dart';

class AddItemContainer extends StatefulWidget {
  const AddItemContainer({super.key});

  @override
  State<AddItemContainer> createState() => _AddItemContainerState();
}

class _AddItemContainerState extends State<AddItemContainer> {
  late final AddItemStateService _stateService;

  @override
  void initState() {
    super.initState();
    _stateService = AddItemStateService(getIt<ItemWriteService>());
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
      child: BlocConsumer<AddItemStateService, AddItemState>(
        listener: (context, state) {
          if (state is AddItemSuccess) context.go('/items');
        },
        builder: (context, state) => ItemFormView(
          formTitle: 'Add item',
          submitLabel: 'Add item',
          isSubmitting: state is AddItemInProgress,
          errorMessage: state is AddItemFailure ? state.message : null,
          onSubmit:
              ({
                required title,
                required creator,
                required publisher,
                required category,
                required format,
                tags,
                topic,
                year,
                description,
                language,
                imageBytes,
                removeImage = false,
                completed = false,
                reference,
              }) => context.read<AddItemStateService>().submit(
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
                imageBytes: imageBytes,
                completed: completed,
                reference: reference,
              ),
          onCancel: () => context.go('/items'),
        ),
      ),
    );
  }
}
