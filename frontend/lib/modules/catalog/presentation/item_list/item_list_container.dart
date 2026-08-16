import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/item_list_state_service.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/catalog_option_labels_util.dart';
import 'package:frontend/modules/catalog/presentation/bulk_export_feedback.dart';
import 'package:frontend/modules/catalog/presentation/item_list/item_list_skeleton.dart';
import 'package:frontend/modules/catalog/presentation/item_list/item_list_view.dart';
import 'package:frontend/shared/layout/item_view_mode.dart';
import 'package:frontend/shared/layout/item_view_mode_state_service.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemListContainer extends StatefulWidget {
  const ItemListContainer({
    this.category,
    this.format,
    this.completed,
    this.enableSort = false,
    super.key,
  });

  final String? category;
  final String? format;
  final bool? completed;
  final bool enableSort;

  @override
  State<ItemListContainer> createState() => _ItemListContainerState();
}

class _ItemListContainerState extends State<ItemListContainer> {
  late final ItemListStateService _stateService;
  late final ItemViewModeStateService _viewModeService;
  late final StreamSubscription<ItemViewMode> _viewModeSubscription;

  @override
  void initState() {
    super.initState();
    _viewModeService = ItemViewModeStateService(
      getIt<SharedPreferences>(),
      'item_list_view_mode',
    );
    _stateService = ItemListStateService(
      getIt<ItemReadService>(),
      category: widget.category,
      format: widget.format,
      completed: widget.completed,
    );
    _viewModeSubscription = _viewModeService.stream.listen((_) => _syncPageSize());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPageSize();
  }

  void _syncPageSize() {
    _stateService.setPageSize(
      itemViewModeGridAwarePageSize(context, _viewModeService.state),
    );
  }

  @override
  void dispose() {
    _viewModeSubscription.cancel();
    _stateService.close();
    _viewModeService.close();
    super.dispose();
  }

  String get _title => widget.completed == true
      ? 'Completed'
      : widget.category != null
      ? categoryLabel(widget.category!)
      : widget.format != null
      ? formatLabel(widget.format!)
      : 'Complete collection';

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _stateService),
        BlocProvider.value(value: _viewModeService),
      ],
      child: BlocBuilder<ItemListStateService, ItemListState>(
        builder: (context, state) => switch (state) {
          ItemListLoading() => const ItemListSkeleton(),
          ItemListError(:final message) => Center(child: Text(message)),
          ItemListLoaded(:final result, :final sortOption) =>
            BlocBuilder<ItemViewModeStateService, ItemViewMode>(
              builder: (context, viewMode) => ItemListView(
                title: _title,
                result: result,
                sortOption: widget.enableSort ? sortOption : null,
                viewMode: viewMode,
                onViewModeChanged: (mode) => context
                    .read<ItemViewModeStateService>()
                    .setMode(mode),
                onSortChanged: (option) => context
                    .read<ItemListStateService>()
                    .setSortOption(option),
                onExport: () => exportItemsWithFeedback(
                  context,
                  _stateService.exportableItems(),
                  _title,
                ),
                onPrevious: () =>
                    context.read<ItemListStateService>().previousPage(),
                onNext: () => context.read<ItemListStateService>().nextPage(),
                onPageChanged: (page) =>
                    context.read<ItemListStateService>().goToPage(page),
                onItemTap: (item) => context.push('/items/${item.id}'),
              ),
            ),
        },
      ),
    );
  }
}
