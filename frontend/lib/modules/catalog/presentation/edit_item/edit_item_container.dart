import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/edit_item_state.dart';
import 'package:frontend/modules/catalog/application/edit_item_state_service.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/item_write_service.dart';
import 'package:frontend/modules/catalog/presentation/item_form/item_form_view.dart';
import 'package:go_router/go_router.dart';
import 'package:pixelarticons/pixel.dart';

class EditItemContainer extends StatefulWidget {
  const EditItemContainer({required this.itemId, super.key});

  final String itemId;

  @override
  State<EditItemContainer> createState() => _EditItemContainerState();
}

class _EditItemContainerState extends State<EditItemContainer> {
  late final EditItemStateService _stateService;

  @override
  void initState() {
    super.initState();
    _stateService = EditItemStateService(
      getIt<ItemReadService>(),
      getIt<ItemWriteService>(),
      widget.itemId,
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
      child: BlocConsumer<EditItemStateService, EditItemState>(
        listener: (context, state) {
          if (state is EditItemSuccess) context.go('/items/${state.itemId}');
          if (state is EditItemDeleted) context.go('/items');
        },
        builder: (context, state) => switch (state) {
          EditItemLoading() => const Center(child: CircularProgressIndicator()),
          EditItemLoadFailure(:final message) => _EditItemErrorView(message: message),
          EditItemReady(:final item, :final isSubmitting, :final submitError) => ItemFormView(
            formTitle: 'Edit item',
            submitLabel: 'Save',
            isSubmitting: isSubmitting,
            errorMessage: submitError,
            initial: ItemFormInitialValues(
              title: item.title,
              creator: item.creator,
              publisher: item.publisher,
              category: item.category,
              format: item.format,
              tags: item.tags,
              topic: item.topic,
              year: item.year,
              description: item.description,
              language: item.language,
              imageUrl: item.imageUrl,
              completed: item.completed,
              reference: item.reference,
            ),
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
                }) => context.read<EditItemStateService>().submit(
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
                  removeImage: removeImage,
                  completed: completed,
                  reference: reference,
                ),
            onCancel: () => context.go('/items/${item.id}'),
            onDelete: () => _confirmAndDelete(context),
          ),
          EditItemDeleting(:final item) => ItemFormView(
            formTitle: 'Edit item',
            submitLabel: 'Save',
            isSubmitting: true,
            errorMessage: null,
            initial: ItemFormInitialValues(
              title: item.title,
              creator: item.creator,
              publisher: item.publisher,
              category: item.category,
              format: item.format,
              tags: item.tags,
              topic: item.topic,
              year: item.year,
              description: item.description,
              language: item.language,
              imageUrl: item.imageUrl,
              completed: item.completed,
              reference: item.reference,
            ),
            onSubmit: ({
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
            }) {},
            onCancel: () {},
          ),
          EditItemSuccess() => const SizedBox.shrink(),
          EditItemDeleted() => const SizedBox.shrink(),
        },
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item'),
        content: const Text(
          'This will permanently delete this item and its image. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<EditItemStateService>().delete();
    }
  }
}

class _EditItemErrorView extends StatelessWidget {
  const _EditItemErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => context.go('/items'),
            icon: const Icon(Pixel.arrowleft),
            label: const Text('Back'),
          ),
          Expanded(child: Center(child: Text(message))),
        ],
      ),
    );
  }
}
