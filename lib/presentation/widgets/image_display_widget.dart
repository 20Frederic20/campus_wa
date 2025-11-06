import 'package:flutter/material.dart';

class ImagesDisplayWidget extends StatelessWidget {
  const ImagesDisplayWidget({
    super.key,
    this.imageUrls,
    this.enableCarousel = false,
    this.allowMultipleImages = true,
    this.height = 220,
  });

  /// Liste des URLs d’images (nullable)
  final List<String>? imageUrls;

  /// Active ou non le mode carrousel
  final bool enableCarousel;

  /// Hauteur de la zone d’image
  final double height;

  /// Si false, ne prend que la première image même si plusieurs sont présentes
  final bool allowMultipleImages;

  @override
  Widget build(BuildContext context) {
    // Cas : aucune image fournie
    if (imageUrls == null || imageUrls!.isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
        ),
      );
    }

    // Si on n’autorise pas plusieurs images → prendre la première
    final displayedImages = allowMultipleImages
        ? imageUrls!
        : [imageUrls!.first];

    // Si carrousel activé ET plusieurs images
    if (enableCarousel && displayedImages.length > 1) {
      return _ImageCarousel(imageUrls: displayedImages, height: height);
    }

    // Sinon → simple image fixe
    return _SingleImage(imageUrl: displayedImages.first, height: height);
  }
}

// === Image unique ===
class _SingleImage extends StatelessWidget {
  const _SingleImage({required this.imageUrl, required this.height});

  final String imageUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          height: height,
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey, size: 60),
          ),
        ),
      ),
    );
  }
}

// === Carrousel ===
class _ImageCarousel extends StatefulWidget {
  const _ImageCarousel({required this.imageUrls, required this.height});

  final List<String> imageUrls;
  final double height;

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  int _currentIndex = 0;
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return Image.network(
                  widget.imageUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 60,
                      ),
                    ),
                  ),
                );
              },
            ),
            // Indicateurs
            Positioned(
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.imageUrls.length, (index) {
                  final isActive = index == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 10 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
