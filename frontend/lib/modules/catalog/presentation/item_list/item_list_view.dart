import 'package:core/shared/pagination/page_result.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_sort_option.dart';
import 'package:frontend/modules/catalog/presentation/item_card_view.dart';
import 'package:frontend/shared/layout/app_footer_view.dart';
import 'package:frontend/shared/layout/item_view_mode.dart';
import 'package:frontend/shared/layout/item_view_mode_toggle.dart';
import 'package:frontend/shared/layout/responsive_item_grid.dart';
import 'package:frontend/shared/pagination/pagination_control_view.dart';
import 'package:frontend/shared/pagination/swipe_page_detector.dart';
import 'package:pixelarticons/pixel.dart';

class ItemListView extends StatelessWidget {
  const ItemListView({
    required this.title,
    required this.result,
    required this.onPrevious,
    required this.onNext,
    required this.onPageChanged,
    required this.onItemTap,
    required this.viewMode,
    required this.onViewModeChanged,
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
  final ValueChanged<int> onPageChanged;
  final void Function(ItemReadModel item) onItemTap;
  final ItemViewMode viewMode;
  final ValueChanged<ItemViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.sizeOf(context).width >= itemViewModeWideBreakpoint;
    final effectiveMode = isWide ? ItemViewMode.grid : viewMode;

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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
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
              if (!isWide)
                ItemViewModeToggle(
                  mode: viewMode,
                  onChanged: onViewModeChanged,
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
            child: SwipePageDetector(
              onSwipeNext: result.hasNextPage ? onNext : null,
              onSwipePrevious: result.hasPreviousPage ? onPrevious : null,
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
                            targetColumns: effectiveMode.targetColumns(isWide),
                            minItemWidth: effectiveMode.minItemWidth(isWide),
                            maxItemWidth: effectiveMode.maxItemWidth(isWide),
                            itemBuilder: (context, item) => ItemCardView(
                              item: item,
                              onTap: () => onItemTap(item),
                              showDetails: effectiveMode.showDetails(isWide),
                            ),
                          ),
                    const SizedBox(height: 24),
                    const AppFooterView(),
                  ],
                ),
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
              onPageChanged: onPageChanged,
            ),
          ],
        ],
      ),
    );
  }
}
