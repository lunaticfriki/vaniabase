import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/catalog_option_labels_util.dart';
import 'package:frontend/shared/layout/app_footer_view.dart';
import 'package:frontend/shared/layout/preview_tile_view.dart';

class CategoryListView extends StatelessWidget {
  const CategoryListView({
    required this.previewImageUrls,
    required this.onCategoryTap,
    super.key,
  });

  final Map<String, List<String>> previewImageUrls;
  final void Function(String category) onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final entry in categoryLabels.entries) ...[
                    PreviewTileView(
                      label: entry.value,
                      previewImageUrls: previewImageUrls[entry.key] ?? const [],
                      onTap: () => onCategoryTap(entry.key),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 16),
                  const AppFooterView(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
