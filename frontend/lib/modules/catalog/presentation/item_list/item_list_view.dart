import 'package:core/shared/pagination/page_result.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_sort_option.dart';
import 'package:frontend/modules/catalog/presentation/item_card_view.dart';
import 'package:frontend/shared/layout/app_footer_view.dart';
import 'package:frontend/shared/layout/responsive_item_grid.dart';
import 'package:frontend/shared/pagination/pagination_control_view.dart';
import 'package:pixelarticons/pixel.dart';

class ItemListView extends StatelessWidget {
  const ItemListView({
    required this.title,
    required this.result,
    required this.onPrevious,
    required this.onNext,
    required this.onItemTap,
    this.sortOption,
    this.onSortChanged,
    this.onExport,
    super.key,
  });

  final String title;
  final PageResult<ItemReadModel> result;
  final ItemSortOption? sortOption;
  final ValueChanged<ItemSortOption>? onSortChanged;
  final VoidCallback? onExport;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final void Function(ItemReadModel item) onItemTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              if (onExport != null)
                IconButton(
                  tooltip: 'Export',
                  icon: const Icon(Pixel.download),
                  onPressed: onExport,
                ),
              if (sortOption != null && onSortChanged != null)
                PopupMenuButton<ItemSortOption>(
                  tooltip: 'Sort',
                  initialValue: sortOption,
                  onSelected: onSortChanged,
                  icon: const Icon(Pixel.sort),
                  itemBuilder: (context) => [
                    for (final option in ItemSortOption.values)
                      PopupMenuItem<ItemSortOption>(
                        value: option,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(itemSortOptionLabels[option]!),
                            ),
                            if (option == sortOption)
                              const Icon(Pixel.check, size: 18),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${result.totalItems} item${result.totalItems == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  result.items.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: Text('No items yet.')),
                        )
                      : ResponsiveItemGrid<ItemReadModel>(
                          items: result.items,
                          keyBuilder: (item) => ValueKey(item.id),
                          itemBuilder: (context, item) => ItemCardView(
                            item: item,
                            onTap: () => onItemTap(item),
                          ),
                        ),
                  const SizedBox(height: 24),
                  const AppFooterView(),
                ],
              ),
            ),
          ),
          if (result.totalPages > 1) ...[
            const SizedBox(height: 12),
            PaginationControlView(
              page: result.page,
              totalPages: result.totalPages,
              hasPreviousPage: result.hasPreviousPage,
              hasNextPage: result.hasNextPage,
              onPrevious: onPrevious,
              onNext: onNext,
            ),
          ],
        ],
      ),
    );
  }
}
