import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GalleryFullScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const GalleryFullScreen({super.key, required this.images, this.initialIndex = 0});

  @override
  State<GalleryFullScreen> createState() => _GalleryFullScreenState();
}

class _GalleryFullScreenState extends State<GalleryFullScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('${_currentIndex + 1} / ${widget.images.length}', style: const TextStyle(color: Colors.white)),
      ),
      extendBodyBehindAppBar: true,
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 1.0,
            maxScale: 5.0,
            child: CachedNetworkImage(
              imageUrl: widget.images[index],
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white)),
              errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
