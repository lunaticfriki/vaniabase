import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/item_list_state_service.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/catalog_option_labels_util.dart';
import 'package:frontend/modules/catalog/presentation/bulk_export_feedback.dart';
import 'package:frontend/modules/catalog/presentation/item_list/item_list_skeleton.dart';
import 'package:frontend/modules/catalog/presentation/item_list/item_list_view.dart';
import 'package:go_router/go_router.dart';

class ItemListContainer extends StatefulWidget {
  const ItemListContainer({
    this.category,
    this.completed,
    this.enableSort = false,
    super.key,
  });

  final String? category;
  final bool? completed;
  final bool enableSort;

  @override
  State<ItemListContainer> createState() => _ItemListContainerState();
}

class _ItemListContainerState extends State<ItemListContainer> {
  late final ItemListStateService _stateService;

  @override
  void initState() {
    super.initState();
    _stateService = ItemListStateService(
      getIt<ItemReadService>(),
      category: widget.category,
      completed: widget.completed,
    );
  }

  @override
  void dispose() {
    _stateService.close();
    super.dispose();
  }

  String get _title => widget.completed == true
      ? 'Completed'
      : widget.category == null
      ? 'Complete collection'
      : categoryLabel(widget.category!);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _stateService,
      child: BlocBuilder<ItemListStateService, ItemListState>(
        builder: (context, state) => switch (state) {
          ItemListLoading() => const ItemListSkeleton(),
          ItemListError(:final message) => Center(child: Text(message)),
          ItemListLoaded(:final result, :final sortOption) => ItemListView(
            title: _title,
            result: result,
            sortOption: widget.enableSort ? sortOption : null,
            onSortChanged: (option) =>
                context.read<ItemListStateService>().setSortOption(option),
            onExport: () => exportItemsWithFeedback(
              context,
              _stateService.exportableItems(),
              _title,
            ),
            onPrevious: () =>
                context.read<ItemListStateService>().previousPage(),
            onNext: () => context.read<ItemListStateService>().nextPage(),
            onItemTap: (item) => context.push('/items/${item.id}'),
          ),
        },
      ),
    );
  }
}
