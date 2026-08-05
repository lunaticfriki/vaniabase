import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/item_write_service.dart';
import 'package:frontend/modules/catalog/presentation/add_item/add_item_cubit.dart';
import 'package:frontend/modules/catalog/presentation/add_item/add_item_state.dart';
import 'package:frontend/modules/catalog/presentation/add_item/add_item_view.dart';
import 'package:go_router/go_router.dart';

class AddItemPage extends StatelessWidget {
  const AddItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddItemCubit(getIt<ItemWriteService>()),
      child: BlocConsumer<AddItemCubit, AddItemState>(
        listener: (context, state) {
          if (state is AddItemSuccess) context.go('/items');
        },
        builder: (context, state) => AddItemView(
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
                imageUrl,
              }) => context.read<AddItemCubit>().submit(
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
                imageUrl: imageUrl,
              ),
          onCancel: () => context.go('/items'),
        ),
      ),
    );
  }
}
