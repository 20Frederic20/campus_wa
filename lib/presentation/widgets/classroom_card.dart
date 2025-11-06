import 'package:campus_wa/domain/models/classroom.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ClassroomCard extends StatelessWidget {
  const ClassroomCard({
    super.key,
    required this.classroom,
    required this.isExpanded,
    required this.onTap,
  });

  final Classroom classroom;
  final bool isExpanded;
  final VoidCallback onTap;

  List<String> get _allImages {
    final List<String> images = [];
    if (classroom.mainImage != null) {
      images.add(classroom.mainImage!);
    }
    images.addAll(
      classroom.annexesImages ?? [],
    ); // Assuming annexesImages is List<String>?
    return images;
  }

  @override
  Widget build(BuildContext context) {
    final images = _allImages;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classroom.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!isExpanded)
                  const Icon(Icons.expand_less, size: 20, color: Colors.grey)
                else
                  const Icon(Icons.expand_more, size: 20, color: Colors.grey),
              ],
            ),
            const Gap(8),

            if (isExpanded)
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // University slug and details
                      Text(
                        classroom.slug,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const Gap(8),

                      if (images.isNotEmpty)
                        SizedBox(
                          height: 200, // Fixed height for carousel
                          child: PageView.builder(
                            itemCount: images.length,
                            // viewportFraction: 1.0 for full-width (or 0.8 for peeking effect)
                            controller: PageController(viewportFraction: 1.0),
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ), // Small side margins
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // Rounded corners
                                  child: Image.network(
                                    images[index],
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit
                                        .cover, // Centers and covers the area
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              height: 200,
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      else ...[
                        // Placeholder if no images
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                      const Gap(8),

                      // ← OPTIONAL: Add dot indicators for carousel (below images)
                      if (images.isNotEmpty && isExpanded)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            images.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 2.0,
                              ),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      const Gap(12),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
