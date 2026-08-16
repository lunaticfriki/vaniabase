import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/presentation/item_card_view.dart';
import 'package:frontend/shared/layout/app_footer_view.dart';
import 'package:frontend/shared/layout/item_view_mode.dart';
import 'package:frontend/shared/layout/item_view_mode_toggle.dart';
import 'package:frontend/shared/layout/responsive_item_grid.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    required this.items,
    required this.onItemTap,
    required this.viewMode,
    required this.onViewModeChanged,
    super.key,
  });

  final List<ItemReadModel> items;
  final void Function(ItemReadModel item) onItemTap;
  final ItemViewMode viewMode;
  final ValueChanged<ItemViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.sizeOf(context).width >= itemViewModeWideBreakpoint;
    final effectiveMode = isWide ? ItemViewMode.grid : viewMode;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Recently added',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                if (!isWide)
                  ItemViewModeToggle(
                    mode: viewMode,
                    onChanged: onViewModeChanged,
                  ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: items.isEmpty
                  ? const Text('No items yet.')
                  : ResponsiveItemGrid<ItemReadModel>(
                      items: items,
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
            ),
          ),
        ),
        const SliverToBoxAdapter(child: AppFooterView()),
      ],
    );
  }
}
