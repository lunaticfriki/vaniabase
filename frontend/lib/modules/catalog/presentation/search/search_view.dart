import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/search_state_service.dart';
import 'package:frontend/modules/catalog/presentation/item_card_view.dart';
import 'package:frontend/shared/layout/app_footer_view.dart';
import 'package:frontend/shared/layout/item_view_mode.dart';
import 'package:frontend/shared/layout/item_view_mode_toggle.dart';
import 'package:frontend/shared/layout/responsive_item_grid.dart';
import 'package:pixelarticons/pixel.dart';

class SearchView extends StatelessWidget {
  const SearchView({
    required this.state,
    required this.controller,
    required this.onQueryChanged,
    required this.onItemTap,
    required this.viewMode,
    required this.onViewModeChanged,
    this.onExport,
    super.key,
  });

  final SearchState state;
  final TextEditingController controller;
  final void Function(String query) onQueryChanged;
  final void Function(ItemReadModel item) onItemTap;
  final ItemViewMode viewMode;
  final ValueChanged<ItemViewMode> onViewModeChanged;
  final VoidCallback? onExport;

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.sizeOf(context).width >= itemViewModeWideBreakpoint;

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
                  'Search',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              if (onExport != null)
                IconButton(
                  tooltip: 'Export',
                  icon: const Icon(Pixel.download),
                  onPressed: onExport,
                ),
              if (!isWide)
                ItemViewModeToggle(
                  mode: viewMode,
                  onChanged: onViewModeChanged,
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            autofocus: true,
            onChanged: onQueryChanged,
            decoration: const InputDecoration(
              labelText: 'Search your catalog',
              helperText:
                  'Matches title, creator, publisher, topic, reference and tags',
              prefixIcon: Icon(Pixel.search),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _SearchResults(
              state: state,
              onItemTap: onItemTap,
              viewMode: viewMode,
              isWide: isWide,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.state,
    required this.onItemTap,
    required this.viewMode,
    required this.isWide,
  });

  final SearchState state;
  final void Function(ItemReadModel item) onItemTap;
  final ItemViewMode viewMode;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final effectiveMode = isWide ? ItemViewMode.grid : viewMode;

    return switch (state) {
      SearchIdle() => const Center(child: Text('Type to search your catalog.')),
      SearchInProgress() => const Center(child: CircularProgressIndicator()),
      SearchError(:final message) => Center(child: Text(message)),
      SearchLoaded(:final query, :final items) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            items.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text('No results for "$query".')),
                  )
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
            const SizedBox(height: 24),
            const AppFooterView(),
          ],
        ),
      ),
    };
  }
}
