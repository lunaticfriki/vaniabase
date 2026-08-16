import 'package:flutter/material.dart';

class ResponsiveItemGrid<T> extends StatelessWidget {
  const ResponsiveItemGrid({
    required this.items,
    required this.itemBuilder,
    this.keyBuilder,
    this.targetColumns = 5,
    this.horizontalPadding = 32,
    this.minItemWidth = _minItemWidth,
    this.maxItemWidth = _maxItemWidth,
    super.key,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Key Function(T item)? keyBuilder;
  final int targetColumns;

  final double horizontalPadding;
  final double minItemWidth;
  final double maxItemWidth;

  static const _spacing = 12.0;
  static const _minItemWidth = 140.0;
  static const _maxItemWidth = 220.0;

  /// How many columns of [minItemWidth] (plus spacing) fit in
  /// [availableWidth], capped at [maxColumns].
  static int columnsThatFit({
    required double availableWidth,
    required double minItemWidth,
    int maxColumns = 100,
  }) {
    return ((availableWidth + _spacing) / (minItemWidth + _spacing))
        .floor()
        .clamp(1, maxColumns);
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final availableWidth = MediaQuery.sizeOf(context).width - horizontalPadding;
    final columnsThatFit = ResponsiveItemGrid.columnsThatFit(
      availableWidth: availableWidth,
      minItemWidth: minItemWidth,
      maxColumns: targetColumns,
    );
    final columns = columnsThatFit.clamp(1, items.length);
    final itemWidth = ((availableWidth - _spacing * (columns - 1)) / columns)
        .clamp(minItemWidth, maxItemWidth);
    final gridWidth = itemWidth * columns + _spacing * (columns - 1);

    return Center(
      child: SizedBox(
        width: gridWidth,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: _spacing,
          runSpacing: _spacing,
          children: [
            for (final item in items)
              SizedBox(
                key: keyBuilder?.call(item),
                width: itemWidth,
                child: itemBuilder(context, item),
              ),
          ],
        ),
      ),
    );
  }
}
