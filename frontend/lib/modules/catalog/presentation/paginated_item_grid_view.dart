import 'package:core/shared/pagination/page_request.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/presentation/item_card_view.dart';
import 'package:frontend/shared/layout/responsive_item_grid.dart';
import 'package:frontend/shared/pagination/pagination_control_view.dart';

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
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    final pageRequest = PageRequest.create(page: _page);
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
        ResponsiveItemGrid<ItemReadModel>(
          items: pageItems,
          keyBuilder: (item) => ValueKey(item.id),
          itemBuilder: (context, item) => ItemCardView(
            item: item,
            onTap: () => widget.onItemTap(item),
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
          ),
        ],
      ],
    );
  }
}
