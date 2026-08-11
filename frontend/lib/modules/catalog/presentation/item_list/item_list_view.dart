import 'package:core/shared/pagination/page_result.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/presentation/item_card_view.dart';
import 'package:frontend/shared/layout/app_footer_view.dart';
import 'package:frontend/shared/layout/responsive_item_grid.dart';
import 'package:frontend/shared/pagination/pagination_control_view.dart';

class ItemListView extends StatelessWidget {
  const ItemListView({
    required this.title,
    required this.result,
    required this.onPrevious,
    required this.onNext,
    required this.onItemTap,
    super.key,
  });

  final String title;
  final PageResult<ItemReadModel> result;
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
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
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
