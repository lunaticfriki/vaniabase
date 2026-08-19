import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/catalog_option_labels_util.dart';
import 'package:pixelarticons/pixel.dart';

class ItemCardView extends StatelessWidget {
  const ItemCardView({
    required this.item,
    required this.onTap,
    this.showDetails = true,
    super.key,
  });

  final ItemReadModel item;
  final VoidCallback onTap;
  final bool showDetails;

  static const _shadowOffset = 6.0;
  static const _shadowInset = 12.0;

  @override
  Widget build(BuildContext context) {
    final image = item.imageUrl.isEmpty
        ? Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Icon(Pixel.imagebroken),
          )
        : CachedNetworkImage(
            imageUrl: item.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            errorWidget: (context, url, error) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Pixel.imagebroken),
            ),
          );

    final sizedImage = AspectRatio(aspectRatio: 3 / 4, child: image);

    return Stack(
      children: [
        Positioned(
          left: _shadowInset,
          top: _shadowInset,
          right: 0,
          bottom: 0,
          child: Container(color: Theme.of(context).colorScheme.primary),
        ),
        Padding(
          padding: const EdgeInsets.only(
            right: _shadowOffset,
            bottom: _shadowOffset,
          ),
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            child: InkWell(
              onTap: onTap,
              child: !showDetails
                  ? sizedImage
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sizedImage,
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
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
