import 'package:flutter/material.dart';
import 'package:frontend/shared/layout/overlay_icon_button.dart';
import 'package:pixelarticons/pixel.dart';

const fullscreenImageKey = Key('fullscreenImage');
const fullscreenImageBackButtonKey = Key('fullscreenImageBackButton');

Future<void> openFullscreenImage(BuildContext context, String imageUrl) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    PageRouteBuilder<void>(
      opaque: true,
      barrierColor: Colors.black,
      pageBuilder: (context, animation, secondaryAnimation) => FullscreenImageView(imageUrl: imageUrl),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

class FullscreenImageView extends StatefulWidget {
  const FullscreenImageView({required this.imageUrl, super.key});

  final String imageUrl;

  @override
  State<FullscreenImageView> createState() => _FullscreenImageViewState();
}

class _FullscreenImageViewState extends State<FullscreenImageView> {
  bool _showChrome = true;

  void _toggleChrome() => setState(() => _showChrome = !_showChrome);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleChrome,
              child: Center(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: widget.imageUrl.isEmpty
                      ? const Icon(Pixel.imagebroken, color: Colors.white54, size: 64)
                      : Image.network(
                          widget.imageUrl,
                          key: fullscreenImageKey,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Pixel.imagebroken, color: Colors.white54, size: 64),
                        ),
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            key: fullscreenImageBackButtonKey,
            opacity: _showChrome ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_showChrome,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: OverlayIconButton(
                      icon: Pixel.arrowleft,
                      label: 'Back',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
