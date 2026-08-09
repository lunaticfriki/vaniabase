import 'package:flutter/material.dart';

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
