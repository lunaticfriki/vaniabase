import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/presentation/catalog_option_labels_util.dart';
import 'package:pixelarticons/pixel.dart';

/// Below this width the image no longer fits comfortably beside the info
/// column, so the layout stacks instead. Shared with [ItemDetailSkeleton] so
/// the loading state mirrors whichever layout is about to render.
const itemDetailWideBreakpoint = 700.0;

/// Identifies the item image in the widget tree regardless of which layout
/// (wide/narrow) rendered it — the two use different widgets under the hood.
const itemDetailImageKey = Key('itemDetailImage');

class ItemDetailView extends StatelessWidget {
  const ItemDetailView({
    required this.item,
    required this.onBack,
    required this.onEdit,
    super.key,
  });

  final ItemReadModel item;
  final VoidCallback onBack;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= itemDetailWideBreakpoint;
    final topRow = Row(
      children: [
        TextButton.icon(
          onPressed: onBack,
          icon: const Icon(Pixel.arrowleft),
          label: const Text('Back'),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onEdit,
          icon: const Icon(Pixel.edit),
          label: const Text('Edit'),
        ),
      ],
    );

    if (isWide) {
      // Fills the page: the top row takes its natural height, the Row
      // below claims the rest via Expanded, so the image can stretch to the
      // full available height instead of just following its aspect ratio.
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            topRow,
            const SizedBox(height: 12),
            Expanded(child: _WideLayout(item: item)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          topRow,
          const SizedBox(height: 12),
          _NarrowLayout(item: item),
        ],
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.item});

  final ItemReadModel item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _ItemImageFill(imageUrl: item.imageUrl)),
        const SizedBox(width: 40),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TitleAndCreator(item: item),
                const SizedBox(height: 20),
                _DetailFields(item: item),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({required this.item});

  final ItemReadModel item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TitleAndCreator(item: item),
        const SizedBox(height: 16),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: _ItemImage(imageUrl: item.imageUrl),
          ),
        ),
        const SizedBox(height: 16),
        _DetailFields(item: item),
      ],
    );
  }
}

class _TitleAndCreator extends StatelessWidget {
  const _TitleAndCreator({required this.item});

  final ItemReadModel item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          item.creator.join(', '),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Unlike [_ItemImage], this doesn't hold to a fixed aspect ratio — it fills
/// whatever box the wide layout's [Expanded] gives it (full page height,
/// half the width), cropping via [BoxFit.cover]. Used only in [_WideLayout];
/// the narrow/stacked layout keeps [_ItemImage]'s fixed aspect ratio since
/// there it's sized by width alone.
class _ItemImageFill extends StatelessWidget {
  const _ItemImageFill({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      key: itemDetailImageKey,
      borderRadius: BorderRadius.circular(8),
      child: imageUrl.isEmpty
          ? Container(
              alignment: Alignment.center,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Pixel.imagebroken, size: 48),
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Pixel.imagebroken, size: 48),
              ),
            ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  const _ItemImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      key: itemDetailImageKey,
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: imageUrl.isEmpty
            ? Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Pixel.imagebroken),
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Pixel.imagebroken),
                ),
              ),
      ),
    );
  }
}

class _DetailFields extends StatelessWidget {
  const _DetailFields({required this.item});

  final ItemReadModel item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(label: 'Publisher', value: item.publisher),
        _DetailRow(label: 'Category', value: categoryLabel(item.category)),
        _DetailRow(label: 'Format', value: formatLabel(item.format)),
        if (item.year > 0) _DetailRow(label: 'Year', value: '${item.year}'),
        if (item.language.isNotEmpty) _DetailRow(label: 'Language', value: item.language),
        if (item.topic.isNotEmpty) _DetailRow(label: 'Topic', value: item.topic),
        if (item.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Tags',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final tag in item.tags) Chip(label: Text(tag))],
          ),
        ],
        if (item.description.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Description',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Text(item.description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
