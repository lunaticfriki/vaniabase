import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/catalog_option_labels_util.dart';
import 'package:pixelarticons/pixel.dart';

class ItemCardView extends StatelessWidget {
  const ItemCardView({required this.item, required this.onTap, super.key});

  final ItemReadModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: item.imageUrl.isEmpty
                  ? Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: const Icon(Pixel.imagebroken),
                    )
                  : CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: const Icon(Pixel.imagebroken),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    item.creator.join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${categoryLabel(item.category)} · ${item.format.map(formatLabel).join(', ')}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
