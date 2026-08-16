import 'package:flutter/material.dart';
import 'package:frontend/shared/layout/item_view_mode.dart';
import 'package:pixelarticons/pixel.dart';

const _icons = {
  ItemViewMode.list: Pixel.list,
  ItemViewMode.twoColumns: Pixel.viewcol,
  ItemViewMode.grid: Pixel.grid,
};

const _labels = {
  ItemViewMode.list: 'List',
  ItemViewMode.twoColumns: '2 per row',
  ItemViewMode.grid: 'Grid',
};

class ItemViewModeToggle extends StatelessWidget {
  const ItemViewModeToggle({
    required this.mode,
    required this.onChanged,
    super.key,
  });

  final ItemViewMode mode;
  final ValueChanged<ItemViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ItemViewMode>(
      tooltip: 'View',
      icon: Icon(_icons[mode]),
      initialValue: mode,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final value in ItemViewMode.values)
          PopupMenuItem<ItemViewMode>(
            value: value,
            child: Row(
              children: [
                Icon(_icons[value], size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(_labels[value]!)),
                if (value == mode) const Icon(Pixel.check, size: 18),
              ],
            ),
          ),
      ],
    );
  }
}
