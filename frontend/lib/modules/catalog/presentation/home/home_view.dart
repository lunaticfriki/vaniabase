import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/presentation/item_card_view.dart';
import 'package:frontend/shared/layout/app_footer_view.dart';
import 'package:frontend/shared/layout/responsive_item_grid.dart';

class HomeView extends StatelessWidget {
  const HomeView({required this.items, required this.onItemTap, super.key});

  final List<ItemReadModel> items;
  final void Function(ItemReadModel item) onItemTap;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Recently added',
              style: Theme.of(context).textTheme.headlineSmall,
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
                      itemBuilder: (context, item) =>
                          ItemCardView(item: item, onTap: () => onItemTap(item)),
                    ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: AppFooterView()),
      ],
    );
  }
}
