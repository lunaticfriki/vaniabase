import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/presentation/catalog_option_labels_util.dart';
import 'package:pixelarticons/pixel.dart';

class CategoryListView extends StatelessWidget {
  const CategoryListView({required this.onCategoryTap, super.key});

  final void Function(String category) onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Categories', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: categoryLabels.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = categoryLabels.entries.elementAt(index);
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: const Icon(Pixel.grid),
                    title: Text(entry.value),
                    trailing: const Icon(Pixel.chevronright),
                    onTap: () => onCategoryTap(entry.key),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
