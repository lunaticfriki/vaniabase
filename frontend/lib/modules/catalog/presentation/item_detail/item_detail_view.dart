import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/catalog_option_labels_util.dart';
import 'package:frontend/modules/catalog/presentation/item_detail/fullscreen_image_view.dart';
import 'package:frontend/shared/layout/overlay_icon_button.dart';
import 'package:pixelarticons/pixel.dart';

const itemDetailWideBreakpoint = 700.0;

const itemDetailImageKey = Key('itemDetailImage');
const itemDetailHeaderKey = Key('itemDetailHeader');
const itemDetailHeroCreatorKey = Key('itemDetailHeroCreator');

class ItemDetailView extends StatelessWidget {
  const ItemDetailView({
    required this.item,
    required this.onBack,
    required this.onEdit,
    required this.onToggleCompleted,
    required this.onTagTap,
    required this.onAuthorTap,
    required this.onPublisherTap,
    required this.onReferenceTap,
    required this.onCategoryTap,
    required this.onFormatTap,
    required this.onYearTap,
    required this.onLanguageTap,
    required this.onTopicTap,
    super.key,
  });

  final ItemReadModel item;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onToggleCompleted;
  final void Function(String tag) onTagTap;
  final void Function(String author) onAuthorTap;
  final void Function(String publisher) onPublisherTap;
  final void Function(String reference) onReferenceTap;
  final void Function(String category) onCategoryTap;
  final void Function(String format) onFormatTap;
  final void Function(int year) onYearTap;
  final void Function(String language) onLanguageTap;
  final void Function(String topic) onTopicTap;

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
          onAuthorTap: onAuthorTap,
          onPublisherTap: onPublisherTap,
          onReferenceTap: onReferenceTap,
          onCategoryTap: onCategoryTap,
          onFormatTap: onFormatTap,
          onYearTap: onYearTap,
          onLanguageTap: onLanguageTap,
          onTopicTap: onTopicTap,
        ),
      );
    }

    return _NarrowItemDetail(
      item: item,
      onBack: onBack,
      onEdit: onEdit,
      onToggleCompleted: onToggleCompleted,
      onTagTap: onTagTap,
      onAuthorTap: onAuthorTap,
      onPublisherTap: onPublisherTap,
      onReferenceTap: onReferenceTap,
      onCategoryTap: onCategoryTap,
      onFormatTap: onFormatTap,
      onYearTap: onYearTap,
      onLanguageTap: onLanguageTap,
      onTopicTap: onTopicTap,
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
    required this.onAuthorTap,
    required this.onPublisherTap,
    required this.onReferenceTap,
    required this.onCategoryTap,
    required this.onFormatTap,
    required this.onYearTap,
    required this.onLanguageTap,
    required this.onTopicTap,
  });

  final ItemReadModel item;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onToggleCompleted;
  final void Function(String tag) onTagTap;
  final void Function(String author) onAuthorTap;
  final void Function(String publisher) onPublisherTap;
  final void Function(String reference) onReferenceTap;
  final void Function(String category) onCategoryTap;
  final void Function(String format) onFormatTap;
  final void Function(int year) onYearTap;
  final void Function(String language) onLanguageTap;
  final void Function(String topic) onTopicTap;

  @override
  State<_NarrowItemDetail> createState() => _NarrowItemDetailState();
}

class _NarrowItemDetailState extends State<_NarrowItemDetail> {
  static const _headerFadeDistance = 120.0;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Rebuilds on every scroll change (not just when the header opacity
    // crosses a new value) because the sticky-image translate below tracks
    // the raw offset continuously for the whole hero image height, not just
    // the short header fade distance.
    _scrollController.addListener(() => setState(() {}));
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
        // The hero image is a normal scrolling child (not a separate Stack
        // layer) so its taps stay in the same gesture arena as the scroll
        // drag — a Stack sibling behind the scroll view would never receive
        // taps, since Scrollable installs an opaque gesture layer across its
        // whole bounds. It's kept visually "stuck" by translating it by the
        // current scroll offset while the sheet below scrolls up over it.
        final rawOffset = _scrollController.hasClients
            ? _scrollController.offset
            : 0.0;
        final stickyOffset = rawOffset
            .clamp(0.0, constraints.maxHeight)
            .toDouble();
        final headerOpacity = (rawOffset / _headerFadeDistance)
            .clamp(0.0, 1.0)
            .toDouble();
        return Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Transform.translate(
                    offset: Offset(0, stickyOffset),
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: _ItemHeroImage(
                        item: widget.item,
                        onAuthorTap: widget.onAuthorTap,
                      ),
                    ),
                  ),
                  Container(
                    color: colorScheme.surface,
                    padding: const EdgeInsets.all(16),
                    child: _NarrowLayout(
                      item: widget.item,
                      onToggleCompleted: widget.onToggleCompleted,
                      onTagTap: widget.onTagTap,
                      onPublisherTap: widget.onPublisherTap,
                      onReferenceTap: widget.onReferenceTap,
                      onCategoryTap: widget.onCategoryTap,
                      onFormatTap: widget.onFormatTap,
                      onYearTap: widget.onYearTap,
                      onLanguageTap: widget.onLanguageTap,
                      onTopicTap: widget.onTopicTap,
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
                color: colorScheme.surface.withValues(alpha: headerOpacity),
                child: Row(
                  children: [
                    OverlayIconButton(
                      icon: Pixel.arrowleft,
                      label: 'Back',
                      onTap: widget.onBack,
                    ),
                    const Spacer(),
                    OverlayIconButton(
                      icon: Pixel.edit,
                      label: 'Edit',
                      onTap: widget.onEdit,
                    ),
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

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.item,
    required this.onBack,
    required this.onEdit,
    required this.onToggleCompleted,
    required this.onTagTap,
    required this.onAuthorTap,
    required this.onPublisherTap,
    required this.onReferenceTap,
    required this.onCategoryTap,
    required this.onFormatTap,
    required this.onYearTap,
    required this.onLanguageTap,
    required this.onTopicTap,
  });

  final ItemReadModel item;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onToggleCompleted;
  final void Function(String tag) onTagTap;
  final void Function(String author) onAuthorTap;
  final void Function(String publisher) onPublisherTap;
  final void Function(String reference) onReferenceTap;
  final void Function(String category) onCategoryTap;
  final void Function(String format) onFormatTap;
  final void Function(int year) onYearTap;
  final void Function(String language) onLanguageTap;
  final void Function(String topic) onTopicTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _ItemHeroImage(item: item, onAuthorTap: onAuthorTap),
        ),
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
                _CompletedBadge(
                  completed: item.completed,
                  onTap: onToggleCompleted,
                ),
                const SizedBox(height: 20),
                _DetailFields(
                  item: item,
                  onTagTap: onTagTap,
                  onPublisherTap: onPublisherTap,
                  onReferenceTap: onReferenceTap,
                  onCategoryTap: onCategoryTap,
                  onFormatTap: onFormatTap,
                  onYearTap: onYearTap,
                  onLanguageTap: onLanguageTap,
                  onTopicTap: onTopicTap,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({
    required this.item,
    required this.onToggleCompleted,
    required this.onTagTap,
    required this.onPublisherTap,
    required this.onReferenceTap,
    required this.onCategoryTap,
    required this.onFormatTap,
    required this.onYearTap,
    required this.onLanguageTap,
    required this.onTopicTap,
  });

  final ItemReadModel item;
  final VoidCallback onToggleCompleted;
  final void Function(String tag) onTagTap;
  final void Function(String publisher) onPublisherTap;
  final void Function(String reference) onReferenceTap;
  final void Function(String category) onCategoryTap;
  final void Function(String format) onFormatTap;
  final void Function(int year) onYearTap;
  final void Function(String language) onLanguageTap;
  final void Function(String topic) onTopicTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CompletedBadge(completed: item.completed, onTap: onToggleCompleted),
        const SizedBox(height: 16),
        _DetailFields(
          item: item,
          onTagTap: onTagTap,
          onPublisherTap: onPublisherTap,
          onReferenceTap: onReferenceTap,
          onCategoryTap: onCategoryTap,
          onFormatTap: onFormatTap,
          onYearTap: onYearTap,
          onLanguageTap: onLanguageTap,
          onTopicTap: onTopicTap,
        ),
      ],
    );
  }
}

class _ItemHeroImage extends StatelessWidget {
  const _ItemHeroImage({required this.item, required this.onAuthorTap});

  final ItemReadModel item;
  final void Function(String author) onAuthorTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.imageUrl.isEmpty
          ? null
          : () => openFullscreenImage(context, item.imageUrl),
      child: Stack(
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
                    stops: const [0, 0.45],
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.55, 1],
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
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
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.creator.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _HeroCreatorLinks(creator: item.creator, onTap: onAuthorTap),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCreatorLinks extends StatelessWidget {
  const _HeroCreatorLinks({required this.creator, required this.onTap});

  final List<String> creator;
  final void Function(String author) onTap;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(color: Colors.white70);
    return Wrap(
      key: itemDetailHeroCreatorKey,
      children: [
        for (var i = 0; i < creator.length; i++) ...[
          InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => onTap(creator[i]),
            child: Text(creator[i], style: style),
          ),
          if (i < creator.length - 1) Text(', ', style: style),
        ],
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
      backgroundColor: completed
          ? colorScheme.primary
          : colorScheme.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: completed ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
      ),
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
          : CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              errorWidget: (context, url, error) => Container(
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Pixel.imagebroken, size: 48),
              ),
            ),
    );
  }
}

class _DetailFields extends StatelessWidget {
  const _DetailFields({
    required this.item,
    required this.onTagTap,
    required this.onPublisherTap,
    required this.onReferenceTap,
    required this.onCategoryTap,
    required this.onFormatTap,
    required this.onYearTap,
    required this.onLanguageTap,
    required this.onTopicTap,
  });

  final ItemReadModel item;
  final void Function(String tag) onTagTap;
  final void Function(String publisher) onPublisherTap;
  final void Function(String reference) onReferenceTap;
  final void Function(String category) onCategoryTap;
  final void Function(String format) onFormatTap;
  final void Function(int year) onYearTap;
  final void Function(String language) onLanguageTap;
  final void Function(String topic) onTopicTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(
          label: 'Publisher',
          value: item.publisher,
          onTap: () => onPublisherTap(item.publisher),
        ),
        if (item.reference.isNotEmpty)
          _DetailRow(
            label: 'Reference',
            value: item.reference,
            onTap: () => onReferenceTap(item.reference),
          ),
        _DetailRow(
          label: 'Category',
          value: categoryLabel(item.category),
          onTap: () => onCategoryTap(item.category),
        ),
        _LinkedValuesRow(
          label: 'Format',
          values: item.format,
          labelBuilder: formatLabel,
          onTap: onFormatTap,
        ),
        if (item.year > 0)
          _DetailRow(
            label: 'Year',
            value: '${item.year}',
            onTap: () => onYearTap(item.year),
          ),
        if (item.language.isNotEmpty)
          _LinkedValuesRow(
            label: 'Language',
            values: item.language,
            onTap: onLanguageTap,
          ),
        if (item.topic.isNotEmpty)
          _DetailRow(
            label: 'Topic',
            value: item.topic,
            onTap: () => onTopicTap(item.topic),
          ),
        if (item.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Tags',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
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
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(item.description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _LinkedValuesRow extends StatelessWidget {
  const _LinkedValuesRow({
    required this.label,
    required this.values,
    required this.onTap,
    this.labelBuilder,
  });

  final String label;
  final List<String> values;
  final void Function(String value) onTap;
  final String Function(String value)? labelBuilder;

  @override
  Widget build(BuildContext context) {
    final valueStyle = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Wrap(
            children: [
              for (var i = 0; i < values.length; i++) ...[
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () => onTap(values[i]),
                  child: Text(
                    labelBuilder?.call(values[i]) ?? values[i],
                    style: valueStyle,
                  ),
                ),
                if (i < values.length - 1) Text(', ', style: valueStyle),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
