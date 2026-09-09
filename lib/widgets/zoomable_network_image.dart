import 'package:flutter/material.dart';

class ZoomableNetworkImage extends StatelessWidget {
  final String imageUrl;
  final String heroTag;
  const ZoomableNetworkImage(
      {super.key, required this.imageUrl, required this.heroTag});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => Navigator.of(context)
            .push(_ImagePreviewRoute(imageUrl: imageUrl, heroTag: heroTag)),
        child: Hero(
            tag: heroTag,
            child: Image.network(imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF152B4B),
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: Colors.white54)))),
      );
}

class _ImagePreviewRoute extends PageRouteBuilder<void> {
  final String imageUrl;
  final String heroTag;
  _ImagePreviewRoute({required this.imageUrl, required this.heroTag})
      : super(
          opaque: false,
          barrierColor: Colors.black87,
          pageBuilder: (_, __, ___) =>
              _ImagePreview(imageUrl: imageUrl, heroTag: heroTag),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                  scale: Tween<double>(begin: .94, end: 1).animate(
                      CurvedAnimation(
                          parent: animation, curve: Curves.easeOutCubic)),
                  child: child)),
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 220),
        );
}

class _ImagePreview extends StatelessWidget {
  final String imageUrl;
  final String heroTag;
  const _ImagePreview({required this.imageUrl, required this.heroTag});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(children: [
          Center(
              child: Hero(
                  tag: heroTag,
                  child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Image.network(imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.white54,
                              size: 64))))),
          SafeArea(
              child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Material(
                          color: Colors.black45,
                          shape: const CircleBorder(),
                          child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close_rounded,
                                  color: Colors.white),
                              tooltip: 'Đóng'))))),
          const SafeArea(
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Text('Chạm và kéo để phóng to ảnh',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13))))),
        ]),
      );
}

