import 'package:core/shared/pagination/page_result.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/presentation/item_card_view.dart';
import 'package:frontend/shared/layout/responsive_item_grid.dart';
import 'package:frontend/shared/pagination/pagination_control_view.dart';

class ItemListView extends StatelessWidget {
  const ItemListView({
    required this.result,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  final PageResult<ItemReadModel> result;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('All items', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            '${result.totalItems} item${result.totalItems == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: result.items.isEmpty
                ? const Center(child: Text('No items yet.'))
                : SingleChildScrollView(
                    child: ResponsiveItemGrid<ItemReadModel>(
                      items: result.items,
                      itemBuilder: (context, item) => ItemCardView(item: item),
                    ),
                  ),
          ),
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
      ),
    );
  }
}
