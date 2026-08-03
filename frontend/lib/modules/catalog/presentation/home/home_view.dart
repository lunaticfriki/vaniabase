import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/presentation/item_card_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({required this.items, required this.onSeeAll, super.key});

  final List<ItemReadModel> items;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recently added',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextButton(onPressed: onSeeAll, child: const Text('See all items')),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text('No items yet.'),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.52,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) => ItemCardView(item: items[index]),
            ),
        ],
      ),
    );
  }
}
