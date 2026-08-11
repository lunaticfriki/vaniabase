import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/search_state_service.dart';
import 'package:frontend/modules/catalog/presentation/item_card_view.dart';
import 'package:frontend/shared/layout/app_footer_view.dart';
import 'package:frontend/shared/layout/responsive_item_grid.dart';
import 'package:pixelarticons/pixel.dart';

class SearchView extends StatelessWidget {
  const SearchView({
    required this.state,
    required this.controller,
    required this.onQueryChanged,
    required this.onItemTap,
    super.key,
  });

  final SearchState state;
  final TextEditingController controller;
  final void Function(String query) onQueryChanged;
  final void Function(ItemReadModel item) onItemTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Search', style: Theme.of(context).textTheme.headlineSmall),
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
            child: _SearchResults(state: state, onItemTap: onItemTap),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.state, required this.onItemTap});

  final SearchState state;
  final void Function(ItemReadModel item) onItemTap;

  @override
  Widget build(BuildContext context) {
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
                    itemBuilder: (context, item) =>
                        ItemCardView(item: item, onTap: () => onItemTap(item)),
                  ),
            const SizedBox(height: 24),
            const AppFooterView(),
          ],
        ),
      ),
    };
  }
}
