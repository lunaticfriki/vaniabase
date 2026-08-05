import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/item_list_state.dart';
import 'package:frontend/modules/catalog/application/item_list_state_service.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/presentation/item_list/item_list_skeleton.dart';
import 'package:frontend/modules/catalog/presentation/item_list/item_list_view.dart';
import 'package:go_router/go_router.dart';

class ItemListContainer extends StatefulWidget {
  const ItemListContainer({super.key});

  @override
  State<ItemListContainer> createState() => _ItemListContainerState();
}

class _ItemListContainerState extends State<ItemListContainer> {
  late final ItemListStateService _stateService;

  @override
  void initState() {
    super.initState();
    _stateService = ItemListStateService(getIt<ItemReadService>());
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
      child: BlocBuilder<ItemListStateService, ItemListState>(
        builder: (context, state) => switch (state) {
          ItemListLoading() => const ItemListSkeleton(),
          ItemListError(:final message) => Center(child: Text(message)),
          ItemListLoaded(:final result) => ItemListView(
            result: result,
            onPrevious: () => context.read<ItemListStateService>().previousPage(),
            onNext: () => context.read<ItemListStateService>().nextPage(),
            onAddItem: () => context.go('/items/new'),
            onItemTap: (item) => context.push('/items/${item.id}'),
          ),
        },
      ),
    );
  }
}
