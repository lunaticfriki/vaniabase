import 'package:core/shared/pagination/page_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/presentation/item_card_view.dart';
import 'package:frontend/shared/layout/item_view_mode.dart';
import 'package:frontend/shared/layout/item_view_mode_state_service.dart';
import 'package:frontend/shared/layout/item_view_mode_toggle.dart';
import 'package:frontend/shared/layout/responsive_item_grid.dart';
import 'package:frontend/shared/pagination/pagination_control_view.dart';
import 'package:frontend/shared/pagination/swipe_page_detector.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Paginates [items] client-side, resetting to page 1 whenever the widget's
/// [Key] changes (e.g. pass `ValueKey(selectedTag)` so switching filters
/// starts back at page 1).
class PaginatedItemGridView extends StatefulWidget {
  const PaginatedItemGridView({
    required this.items,
    required this.onItemTap,
    super.key,
  });

  final List<ItemReadModel> items;
  final void Function(ItemReadModel item) onItemTap;

  @override
  State<PaginatedItemGridView> createState() => _PaginatedItemGridViewState();
}

class _PaginatedItemGridViewState extends State<PaginatedItemGridView> {
  late final ItemViewModeStateService _viewModeService;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _viewModeService = ItemViewModeStateService(
      getIt<SharedPreferences>(),
      'item_list_view_mode',
    );
  }

  @override
  void dispose() {
    _viewModeService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _viewModeService,
      child: BlocBuilder<ItemViewModeStateService, ItemViewMode>(
        builder: (context, viewMode) => _build(context, viewMode),
      ),
    );
  }

  Widget _build(BuildContext context, ItemViewMode viewMode) {
    final isWide =
        MediaQuery.sizeOf(context).width >= itemViewModeWideBreakpoint;
    final effectiveMode = isWide ? ItemViewMode.grid : viewMode;

    final pageRequest = PageRequest.create(
      page: _page,
      pageSize: itemViewModeGridAwarePageSize(context, viewMode),
    );
    final start = pageRequest.offset;
    final end = (start + pageRequest.limit).clamp(0, widget.items.length);
    final pageItems = start >= widget.items.length
        ? const <ItemReadModel>[]
        : widget.items.sublist(start, end);
    final totalPages = widget.items.isEmpty
        ? 1
        : (widget.items.length / pageRequest.pageSize).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isWide)
          Align(
            alignment: Alignment.centerRight,
            child: ItemViewModeToggle(
              mode: viewMode,
              onChanged: _viewModeService.setMode,
            ),
          ),
        SwipePageDetector(
          onSwipeNext: _page < totalPages ? () => setState(() => _page++) : null,
          onSwipePrevious: _page > 1 ? () => setState(() => _page--) : null,
          child: ResponsiveItemGrid<ItemReadModel>(
            items: pageItems,
            keyBuilder: (item) => ValueKey(item.id),
            targetColumns: effectiveMode.targetColumns(isWide),
            minItemWidth: effectiveMode.minItemWidth(isWide),
            maxItemWidth: effectiveMode.maxItemWidth(isWide),
            itemBuilder: (context, item) => ItemCardView(
              item: item,
              onTap: () => widget.onItemTap(item),
              showDetails: effectiveMode.showDetails(isWide),
            ),
          ),
        ),
        if (totalPages > 1) ...[
          const SizedBox(height: 12),
          PaginationControlView(
            page: _page,
            totalPages: totalPages,
            hasPreviousPage: _page > 1,
            hasNextPage: _page < totalPages,
            onPrevious: () => setState(() => _page--),
            onNext: () => setState(() => _page++),
            onPageChanged: (page) => setState(() => _page = page),
          ),
        ],
      ],
    );
  }
}
