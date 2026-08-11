import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/catalog_option_labels_util.dart';
import 'package:frontend/shared/layout/app_footer_view.dart';
import 'package:pixelarticons/pixel.dart';

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
          Text('Categories', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final entry in categoryLabels.entries) ...[
                    _CategoryTile(
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

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.previewImageUrls,
    required this.onTap,
  });

  final String label;
  final List<String> previewImageUrls;
  final VoidCallback onTap;

  static const _thumbnailSize = 48.0;
  static const _thumbnailSpacing = 8.0;
  static const _reservedForLabel = 120.0;
  static const _reservedForArrow = 36.0;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableForThumbnails =
                  constraints.maxWidth - _reservedForLabel - _reservedForArrow;
              final thumbnailsThatFit =
                  ((availableForThumbnails + _thumbnailSpacing) /
                          (_thumbnailSize + _thumbnailSpacing))
                      .floor()
                      .clamp(0, previewImageUrls.length);
              final shownImageUrls = previewImageUrls.take(thumbnailsThatFit);

              return Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  for (final imageUrl in shownImageUrls) ...[
                    const SizedBox(width: _thumbnailSpacing),
                    _CategoryPreviewThumbnail(imageUrl: imageUrl),
                  ],
                  const SizedBox(width: 12),
                  const Icon(Pixel.chevronright),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CategoryPreviewThumbnail extends StatelessWidget {
  const _CategoryPreviewThumbnail({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: _CategoryTile._thumbnailSize,
        height: _CategoryTile._thumbnailSize,
        child: imageUrl.isEmpty
            ? Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Pixel.imagebroken, size: 20),
              )
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Pixel.imagebroken, size: 20),
                ),
              ),
      ),
    );
  }
}
