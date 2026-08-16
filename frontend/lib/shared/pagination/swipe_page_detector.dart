import 'package:flutter/material.dart';

/// Wraps [child] so a fast enough horizontal drag pages forward/backward,
/// mirroring whatever prev/next buttons already do — not a replacement for
/// them, just a second way to trigger the same action.
class SwipePageDetector extends StatelessWidget {
  const SwipePageDetector({
    required this.child,
    required this.onSwipeNext,
    required this.onSwipePrevious,
    super.key,
  });

  final Widget child;
  final VoidCallback? onSwipeNext;
  final VoidCallback? onSwipePrevious;

  static const _velocityThreshold = 200.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity <= -_velocityThreshold) {
          onSwipeNext?.call();
        } else if (velocity >= _velocityThreshold) {
          onSwipePrevious?.call();
        }
      },
      child: child,
    );
  }
}
