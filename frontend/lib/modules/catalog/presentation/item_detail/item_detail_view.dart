import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/catalog_option_labels_util.dart';
import 'package:pixelarticons/pixel.dart';

const itemDetailWideBreakpoint = 700.0;

const itemDetailImageKey = Key('itemDetailImage');
const itemDetailHeaderKey = Key('itemDetailHeader');

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

    if (isWide) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: _WideLayout(
          item: item,
          onBack: onBack,
          onEdit: onEdit,
          onToggleCompleted: onToggleCompleted,
          onTagTap: onTagTap,
        ),
      );
    }

    return _NarrowItemDetail(
      item: item,
      onBack: onBack,
      onEdit: onEdit,
      onToggleCompleted: onToggleCompleted,
      onTagTap: onTagTap,
    );
  }
}

class _NarrowItemDetail extends StatefulWidget {
  const _NarrowItemDetail({
    required this.item,
    required this.onBack,
    required this.onEdit,
    required this.onToggleCompleted,
    required this.onTagTap,
  });

  final ItemReadModel item;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onToggleCompleted;
  final void Function(String tag) onTagTap;

  @override
  State<_NarrowItemDetail> createState() => _NarrowItemDetailState();
}

class _NarrowItemDetailState extends State<_NarrowItemDetail> {
  static const _headerFadeDistance = 120.0;

  final _scrollController = ScrollController();
  double _headerOpacity = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final opacity = (_scrollController.offset / _headerFadeDistance).clamp(0.0, 1.0);
    if (opacity != _headerOpacity) setState(() => _headerOpacity = opacity);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: constraints.maxHeight,
                    child: _ItemHeroImage(item: widget.item),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _NarrowLayout(
                      item: widget.item,
                      onToggleCompleted: widget.onToggleCompleted,
                      onTagTap: widget.onTagTap,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                key: itemDetailHeaderKey,
                padding: EdgeInsets.only(
                  top: MediaQuery.paddingOf(context).top,
                  left: 4,
                  right: 4,
                  bottom: 4,
                ),
                color: colorScheme.surface.withValues(alpha: _headerOpacity),
                child: Row(
                  children: [
                    _OverlayIconButton(icon: Pixel.arrowleft, label: 'Back', onTap: widget.onBack),
                    const Spacer(),
                    _OverlayIconButton(icon: Pixel.edit, label: 'Edit', onTap: widget.onEdit),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OverlayIconButton extends StatelessWidget {
  const _OverlayIconButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: Colors.black.withValues(alpha: 0.35),
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.item,
    required this.onBack,
    required this.onEdit,
    required this.onToggleCompleted,
    required this.onTagTap,
  });

  final ItemReadModel item;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onToggleCompleted;
  final void Function(String tag) onTagTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _ItemHeroImage(item: item)),
        const SizedBox(width: 40),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                ),
                const SizedBox(height: 12),
                _CompletedBadge(completed: item.completed, onTap: onToggleCompleted),
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
        _CompletedBadge(completed: item.completed, onTap: onToggleCompleted),
        const SizedBox(height: 16),
        _DetailFields(item: item, onTagTap: onTagTap),
      ],
    );
  }
}

class _ItemHeroImage extends StatelessWidget {
  const _ItemHeroImage({required this.item});

  final ItemReadModel item;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _ItemImageFill(imageUrl: item.imageUrl),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.55, 1],
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              if (item.creator.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.creator.join(', '),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ],
          ),
        ),
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
