import 'package:flutter/material.dart';

/// Lays out [items] centered in [targetColumns] columns (two rows for a
/// 10-item page) on wide screens, falling back to more (narrower-column)
/// rows on small screens. Only the width of each item is constrained — its
/// height is left to size itself naturally, so item content is never clipped
/// or overflows regardless of font metrics.
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
  final double horizontalPadding;

  static const _spacing = 12.0;
  static const _minItemWidth = 140.0;
  static const _maxItemWidth = 220.0;

  @override
  Widget build(BuildContext context) {
    final availableWidth = MediaQuery.sizeOf(context).width - horizontalPadding;
    final columns = targetColumns.clamp(1, items.length);
    final itemWidth =
        ((availableWidth - _spacing * (columns - 1)) / columns).clamp(
          _minItemWidth,
          _maxItemWidth,
        );

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: _spacing,
      runSpacing: _spacing,
      children: [
        for (final item in items) SizedBox(width: itemWidth, child: itemBuilder(context, item)),
      ],
    );
  }
}
