import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:campus_wa/core/theme/app_theme.dart';
import 'package:campus_wa/domain/models/classroom.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class ClassroomCard extends StatelessWidget {
  const ClassroomCard({
    super.key,
    required this.classroom,
    required this.isExpanded,
    required this.onTap,
    this.onDirections,
    this.onOpenInGoogleMaps,
    this.onClassroomUpdated,
  });

  final Classroom classroom;
  final bool isExpanded;
  final VoidCallback onTap;
  final Future<void> Function(LatLng)? onDirections;
  final Future<void> Function(LatLng)? onOpenInGoogleMaps;
  final void Function(Classroom? updated)? onClassroomUpdated;

  List<String> get _allImages {
    final List<String> images = [];
    images.add(classroom.mainImage!);
    images.addAll(
      classroom.annexesImages ?? [],
    ); // Assuming annexesImages is List<String>?
    return images;
  }

  void _openFullScreenImage(
    String imageUrl,
    BuildContext context, {
    String? heroTag,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                Hero(
                  tag: heroTag ?? 'fullscreen_image',
                  child: Center(
                    child: InteractiveViewer(
                      panEnabled: true,
                      boundaryMargin: const EdgeInsets.all(20),
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[900],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    onVerticalDragEnd: (details) {
                      if (details.velocity.pixelsPerSecond.dy > 300) {
                        Navigator.of(routeContext).pop();
                      }
                    },
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.of(routeContext).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        fullscreenDialog: true,
        settings: const RouteSettings(name: 'fullscreen_image'),
      ),
    );
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
                InkWell(
                  onTap: () {
                    debugPrint(
                      'Icon tapped - toggling expansion',
                    ); // Debug: Check console
                    onTap();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0), // Hit area ~28px
                    child: Icon(
                      isExpanded ? Icons.expand_more : Icons.expand_less,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
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

                      Text(
                        'Université : ${classroom.UniversityName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Gap(12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await context.push(
                              '/classrooms/${classroom.id}/edit',
                            );
                            log(result.toString());
                            if (result is Classroom) {
                              onClassroomUpdated?.call(result);
                            } else {
                              onClassroomUpdated?.call(null);
                            }
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Modifier cette salle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                      const Gap(12),

                      // if (classroom.lat != null) ...[
                      //   Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       const Expanded(
                      //         child: Text(
                      //           'Ouvrir dans Google Maps',
                      //           style: TextStyle(
                      //             fontSize: 14,
                      //             color: AppColors.textPrimary,
                      //             fontWeight: FontWeight.w500,
                      //           ),
                      //         ),
                      //       ),
                      //       IconButton(
                      //         onPressed: () => openGoogleMaps(
                      //           context: context,
                      //           position: LatLng(
                      //             double.parse(classroom.lat),
                      //             double.parse(classroom.lng),
                      //           ),
                      //         ),
                      //         icon: const Icon(
                      //           Icons.map_outlined,
                      //           color: Colors.blue,
                      //           size: 24,
                      //         ),
                      //         tooltip: 'Ouvrir Google Maps',
                      //       ),
                      //     ],
                      //   ),
                      //   const Gap(8),
                      // ],
                      if (images.isNotEmpty)
                        SizedBox(
                          height: 200,
                          child: PageView.builder(
                            itemCount: images.length,
                            controller: PageController(viewportFraction: 1.0),
                            itemBuilder: (context, index) => GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _openFullScreenImage(
                                images[index],
                                context,
                                heroTag: '${classroom.id}_img_$index',
                              ),
                              child: Hero(
                                tag: '${classroom.id}_img_$index',
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: images[index],
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        height: 200,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
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
                                ),
                              ),
                            ),
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

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: (onDirections != null)
                                    ? () {
                                        final dest = LatLng(
                                          double.parse(classroom.lat),
                                          double.parse(classroom.lng),
                                        );
                                        onDirections!(dest);
                                      }
                                    : null,
                                icon: const Icon(
                                  Icons.directions,
                                  color: AppColors.white,
                                ),
                                label: const Text(
                                  'Itinéraire',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentRed,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: (onOpenInGoogleMaps != null)
                                    ? () {
                                        final dest = LatLng(
                                          double.parse(classroom.lat),
                                          double.parse(classroom.lng),
                                        );
                                        onOpenInGoogleMaps!(dest);
                                      }
                                    : null,
                                icon: const Icon(
                                  Icons.map,
                                  color: AppColors.backgroundLight,
                                ),
                                label: const Text(
                                  'Google Maps',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4285F4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
