import 'package:flutter/material.dart';

/// Clips a diagonal notch out of the top-right corner, used for the app's
/// signature "cut corner" look on covers and overlay buttons.
class TopRightCornerClipper extends CustomClipper<Path> {
  const TopRightCornerClipper({this.cut = 20});

  final double cut;

  @override
  Path getClip(Size size) {
    final effectiveCut = cut.clamp(0.0, size.shortestSide);
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - effectiveCut, 0)
      ..lineTo(size.width, effectiveCut)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant TopRightCornerClipper oldClipper) =>
      cut != oldClipper.cut;
}

/// Diagonal notches cut out of the top-right and/or bottom-left corners, as
/// an [OutlinedBorder] so it can be used as a [Card], [Material], or [Chip]
/// `shape` and clip the whole container (background, ink splashes, and
/// content) instead of just one child. Set a cut to 0 to leave that corner
/// square.
class NotchedCornersShapeBorder extends OutlinedBorder {
  const NotchedCornersShapeBorder({
    this.topRightCut = 20,
    this.bottomLeftCut = 0,
    super.side,
  });

  final double topRightCut;
  final double bottomLeftCut;

  @override
  NotchedCornersShapeBorder copyWith({
    BorderSide? side,
    double? topRightCut,
    double? bottomLeftCut,
  }) {
    return NotchedCornersShapeBorder(
      side: side ?? this.side,
      topRightCut: topRightCut ?? this.topRightCut,
      bottomLeftCut: bottomLeftCut ?? this.bottomLeftCut,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _path(rect.deflate(side.width));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => _path(rect);

  Path _path(Rect rect) {
    final trCut = topRightCut.clamp(0.0, rect.shortestSide);
    final blCut = bottomLeftCut.clamp(0.0, rect.shortestSide);
    return Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.right - trCut, rect.top)
      ..lineTo(rect.right, rect.top + trCut)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left + blCut, rect.bottom)
      ..lineTo(rect.left, rect.bottom - blCut)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    canvas.drawPath(_path(rect.deflate(side.width / 2)), side.toPaint());
  }

  @override
  ShapeBorder scale(double t) => NotchedCornersShapeBorder(
    side: side.scale(t),
    topRightCut: topRightCut * t,
    bottomLeftCut: bottomLeftCut * t,
  );
}
