import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/presentation/item_list/item_list_cubit.dart';
import 'package:frontend/modules/catalog/presentation/item_list/item_list_skeleton.dart';
import 'package:frontend/modules/catalog/presentation/item_list/item_list_state.dart';
import 'package:frontend/modules/catalog/presentation/item_list/item_list_view.dart';

class ItemListPage extends StatelessWidget {
  const ItemListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ItemListCubit(getIt<ItemReadService>()),
      child: BlocBuilder<ItemListCubit, ItemListState>(
        builder: (context, state) => switch (state) {
          ItemListLoading() => const ItemListSkeleton(),
          ItemListError(:final message) => Center(child: Text(message)),
          ItemListLoaded(:final result) => ItemListView(
            result: result,
            onPrevious: () => context.read<ItemListCubit>().previousPage(),
            onNext: () => context.read<ItemListCubit>().nextPage(),
          ),
        },
      ),
    );
  }
}
