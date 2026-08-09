import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/presentation/catalog_option_labels_util.dart';
import 'package:pixelarticons/pixel.dart';

const itemDetailWideBreakpoint = 700.0;

const itemDetailImageKey = Key('itemDetailImage');

class ItemDetailView extends StatelessWidget {
  const ItemDetailView({
    required this.item,
    required this.onBack,
    required this.onEdit,
    required this.onToggleCompleted,
    required this.onTagTap,
    super.key,
  });

  final ItemReadModel item;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onToggleCompleted;
  final void Function(String tag) onTagTap;

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
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            topRow,
            const SizedBox(height: 12),
            Expanded(
              child: _WideLayout(
                item: item,
                onToggleCompleted: onToggleCompleted,
                onTagTap: onTagTap,
              ),
            ),
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
          _NarrowLayout(item: item, onToggleCompleted: onToggleCompleted, onTagTap: onTagTap),
        ],
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.item, required this.onToggleCompleted, required this.onTagTap});

  final ItemReadModel item;
  final VoidCallback onToggleCompleted;
  final void Function(String tag) onTagTap;

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
                _TitleAndCreator(item: item, onToggleCompleted: onToggleCompleted),
                const SizedBox(height: 20),
                _DetailFields(item: item, onTagTap: onTagTap),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({required this.item, required this.onToggleCompleted, required this.onTagTap});

  final ItemReadModel item;
  final VoidCallback onToggleCompleted;
  final void Function(String tag) onTagTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TitleAndCreator(item: item, onToggleCompleted: onToggleCompleted),
        const SizedBox(height: 16),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: _ItemImage(imageUrl: item.imageUrl),
          ),
        ),
        const SizedBox(height: 16),
        _DetailFields(item: item, onTagTap: onTagTap),
      ],
    );
  }
}

class _TitleAndCreator extends StatelessWidget {
  const _TitleAndCreator({required this.item, required this.onToggleCompleted});

  final ItemReadModel item;
  final VoidCallback onToggleCompleted;

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
        const SizedBox(height: 8),
        _CompletedBadge(completed: item.completed, onTap: onToggleCompleted),
      ],
    );
  }
}

class _CompletedBadge extends StatelessWidget {
  const _CompletedBadge({required this.completed, required this.onTap});

  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ActionChip(
      avatar: Icon(
        completed ? Pixel.check : Pixel.clock,
        size: 16,
        color: completed ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
      ),
      label: Text(completed ? 'Completed' : 'Not completed'),
      onPressed: onTap,
      backgroundColor: completed ? colorScheme.primary : colorScheme.surfaceContainerHighest,
      labelStyle: TextStyle(color: completed ? colorScheme.onPrimary : colorScheme.onSurfaceVariant),
    );
  }
}

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
  const _DetailFields({required this.item, required this.onTagTap});

  final ItemReadModel item;
  final void Function(String tag) onTagTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(label: 'Publisher', value: item.publisher),
        if (item.reference.isNotEmpty) _DetailRow(label: 'Reference', value: item.reference),
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
            children: [
              for (final tag in item.tags)
                ActionChip(label: Text(tag), onPressed: () => onTagTap(tag)),
            ],
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
