import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/presentation/item_detail/item_detail_view.dart';
import 'package:pixelarticons/pixel.dart';

class ItemDetailSkeleton extends StatelessWidget {
  const ItemDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= itemDetailWideBreakpoint;
    final placeholderColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    Widget block({double? width, required double height}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: placeholderColor, borderRadius: BorderRadius.circular(8)),
      );
    }

    final titleAndCreator = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        block(width: 260, height: 28),
        const SizedBox(height: 8),
        block(width: 160, height: 20),
      ],
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < 4; i++) ...[
          block(width: 200, height: 16),
          const SizedBox(height: 12),
        ],
      ],
    );

    final backButton = TextButton.icon(
      onPressed: null,
      icon: const Icon(Pixel.arrowleft),
      label: const Text('Back'),
    );

    if (isWide) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            backButton,
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: block(height: double.infinity)),
                  const SizedBox(width: 40),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [titleAndCreator, const SizedBox(height: 20), details],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final image = AspectRatio(aspectRatio: 3 / 4, child: block(height: double.infinity));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          backButton,
          const SizedBox(height: 12),
          titleAndCreator,
          const SizedBox(height: 16),
          Center(child: SizedBox(width: 280, child: image)),
          const SizedBox(height: 16),
          details,
        ],
      ),
    );
  }
}
