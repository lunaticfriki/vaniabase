import 'package:flutter/material.dart';

/// Lays out [items] in up to [targetColumns] columns (two rows for a
/// 10-item page on a wide screen), centered in the available width, and
/// reflows to fewer (but never narrower than [_minItemWidth]) columns as the
/// screen narrows. Only the width of each item is constrained — its height
/// is left to size itself naturally, so item content is never clipped or
/// overflows regardless of font metrics.
class ResponsiveItemGrid<T> extends StatelessWidget {
  const ResponsiveItemGrid({
    required this.items,
    required this.itemBuilder,
    this.targetColumns = 5,
    this.horizontalPadding = 32,
    super.key,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final int targetColumns;

  /// Horizontal space already consumed by ancestors (e.g. an outer
  /// `Padding`) that [MediaQuery]'s full window width doesn't account for.
  /// A plain [LayoutBuilder] would read this directly off incoming
  /// constraints, but some ancestors this grid is used under (a
  /// `SliverFillRemaining` with `hasScrollBody: false`, on the home page)
  /// query their child's *intrinsic* size, and `LayoutBuilder` cannot
  /// answer that — so width is derived from `MediaQuery` instead.
  final double horizontalPadding;

  static const _spacing = 12.0;
  static const _minItemWidth = 140.0;
  static const _maxItemWidth = 220.0;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final availableWidth = MediaQuery.sizeOf(context).width - horizontalPadding;
    final columnsThatFit = ((availableWidth + _spacing) / (_minItemWidth + _spacing))
        .floor()
        .clamp(1, targetColumns);
    final columns = columnsThatFit.clamp(1, items.length);
    final itemWidth = ((availableWidth - _spacing * (columns - 1)) / columns).clamp(
      _minItemWidth,
      _maxItemWidth,
    );
    final gridWidth = itemWidth * columns + _spacing * (columns - 1);

    return Center(
      child: SizedBox(
        width: gridWidth,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: _spacing,
          runSpacing: _spacing,
          children: [
            for (final item in items) SizedBox(width: itemWidth, child: itemBuilder(context, item)),
          ],
        ),
      ),
    );
  }
}
